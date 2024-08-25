package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(func(ctx context.Context) (string, error) {
		return Crontab()
	})
}

func Crontab() (string, error) {
	fmt.Println("Product crontab")

	return "Ok", nil
}
