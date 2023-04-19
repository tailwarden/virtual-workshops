package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/sashabaranov/go-openai"
)

func handler() error {
	client := openai.NewClient(os.Getenv("OPENAI_TOKEN"))
	resp, err := client.CreateChatCompletion(
		context.Background(),
		openai.ChatCompletionRequest{
			Model: openai.GPT3Dot5Turbo,
			Messages: []openai.ChatCompletionMessage{
				{
					Role:    openai.ChatMessageRoleUser,
					Content: `give me 45min workout plan`,
				},
			},
		},
	)

	if err != nil {
		return err
	}

	fmt.Println(resp.Choices[0].Message.Content)

	return nil
}

func main() {
	lambda.Start(handler)
}
