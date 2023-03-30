package main

import (
	"fmt"
	"log"
	"strings"
	"sync"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"github.com/spf13/cobra"
)

var routeTableIdsParam string
var cidrBlocksParam string
var networkInterfaceId string
var maxConcurrency int
var maxRetries int

func main() {
	var rootCmd = &cobra.Command{
		Use:   "aws-batch-routes",
		Short: "AWS batch route management CLI",
		Long:  `A simple CLI to manage AWS EC2 routes concurrently.`,
		Run:   execute,
	}

	rootCmd.Flags().StringVarP(&routeTableIdsParam, "routeTableIds", "r", "", "Comma-separated list of Route Table IDs (required)")
	rootCmd.Flags().StringVarP(&cidrBlocksParam, "cidrBlocks", "c", "", "Comma-separated list of CIDR Blocks (required)")
	rootCmd.Flags().StringVarP(&networkInterfaceId, "networkInterfaceId", "n", "", "Network Interface ID (required)")
	rootCmd.Flags().IntVarP(&maxConcurrency, "maxConcurrency", "p", 20, "Max concurrency for AWS API requests (default: 20)")
	rootCmd.Flags().IntVarP(&maxRetries, "maxRetries", "t", 5, "Max retries for AWS API requests (default: 5)")

	rootCmd.MarkFlagRequired("routeTableIds")
	rootCmd.MarkFlagRequired("cidrBlocks")
	rootCmd.MarkFlagRequired("networkInterfaceId")

	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

func execute(cmd *cobra.Command, args []string) {
	routeTableIds := strings.Split(routeTableIdsParam, ",")
	cidrBlocks := strings.Split(cidrBlocksParam, ",")

	sess, err := session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	})

	if err != nil {
		log.Fatalf("Failed to create session: %v", err)
	}

	ec2Svc := ec2.New(sess)

	var wg sync.WaitGroup
	sem := make(chan struct{}, maxConcurrency)

	for _, rtbID := range routeTableIds {
		for _, cidrBlock := range cidrBlocks {
			wg.Add(1)
			sem <- struct{}{} // Acquire a semaphore
			go func(rtbID, cidrBlock string) {
				defer wg.Done()
				fmt.Printf("Starting manageRoutes for RouteTable: %s and CIDR: %s\n", rtbID, cidrBlock)
				startTime := time.Now()
				retryWithBackoff(func() error {
					return manageRoutes(ec2Svc, rtbID, cidrBlock, networkInterfaceId)
				})
				elapsedTime := time.Since(startTime)
				fmt.Printf("Finished manageRoutes for RouteTable: %s and CIDR: %s in %s\n", rtbID, cidrBlock, elapsedTime)
				<-sem // Release a semaphore
			}(rtbID, cidrBlock)
		}
	}

	wg.Wait()
	fmt.Println("Done")
}

func retryWithBackoff(fn func() error) {
	for i := 1; i <= maxRetries; i++ {
		err := fn()
		if err == nil {
			break
		}

		if strings.Contains(err.Error(), "RequestLimitExceeded") {
			if i == maxRetries {
				fmt.Printf("Reached max retries: %v\n", err)
			} else {
				waitDuration := time.Duration(1<<i) * time.Second
				time.Sleep(waitDuration)
			}
		} else {
			break
		}
	}
}

func manageRoutes(svc *ec2.EC2, rtbID, cidrBlock, networkInterfaceId string) error {
	// Delete existing route if it exists
	input := &ec2.DeleteRouteInput{
		RouteTableId:         aws.String(rtbID),
		DestinationCidrBlock: aws.String(cidrBlock),
	}
	_, err := svc.DeleteRoute(input)
	if err != nil {
		if !strings.Contains(err.Error(), "InvalidRoute.NotFound") {
			fmt.Printf("Failed to delete route for %s in %s: %v\n", cidrBlock, rtbID, err)
			return err
		}
	}

	fmt.Printf("Deleted route for %s in %s\n", cidrBlock, rtbID)

	// Create a new route targeting the provided network interface Id
	createRouteInput := &ec2.CreateRouteInput{
		RouteTableId:         aws.String(rtbID),
		DestinationCidrBlock: aws.String(cidrBlock),
		NetworkInterfaceId:   aws.String(networkInterfaceId),
	}

	_, err = svc.CreateRoute(createRouteInput)
	if err != nil {
		fmt.Printf("Failed to create route for %s in %s: %v\n", cidrBlock, rtbID, err)
		return err
	}

	fmt.Println(1)
	fmt.Printf("Created route for %s in %s\n", cidrBlock, rtbID)
	return nil
}
