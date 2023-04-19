package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Output struct {
	Message string
}

func handler() (events.APIGatewayProxyResponse, error) {
	output := Output{
		Message: fmt.Sprintf("Running in %s", os.Getenv("ENVIRONMENT")),
	}

	data, _ := json.Marshal(output)

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(data),
	}, nil
}

func main() {
	lambda.Start(handler)
}
