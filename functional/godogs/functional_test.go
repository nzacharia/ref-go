package godogs

import (
	"fmt"
	"github.com/cucumber/godog"
	"github.com/go-resty/resty/v2"
	log "github.com/sirupsen/logrus"
	"os"
)

var baseUri = getBaseURI()
var request *resty.Request
var response resty.Response

func aRestService() {
	httpClient := resty.New()
	request = httpClient.R()
}

func iCallTheHelloWorldEndpoint() error {
	log.Printf("Hitting endpoint %s\n", baseUri)
	httpResponse, err := request.Get(baseUri + "/hello")

	if err != nil {
		return fmt.Errorf("call to %s was unsuccessfull, error: %v", baseUri, err)
	}

	response = *httpResponse
	return nil
}

func anOkResponseIsReturned() error {
	if response.IsSuccess() == true {
		return nil
	}
	return fmt.Errorf("response not successful, response code: %d, error: %v", response.StatusCode(), response.Error())
}

func InitializeScenario(ctx *godog.ScenarioContext) {
	ctx.Step(`^a rest service$`, aRestService)
	ctx.Step(`^an ok response is returned$`, anOkResponseIsReturned)
	ctx.Step(`^I call the hello world endpoint$`, iCallTheHelloWorldEndpoint)
}

func getBaseURI() string {
	serviceEndpoint := os.Getenv("SERVICE_ENDPOINT")

	if serviceEndpoint == "" {
		return "http://service:8080"
	}
	return serviceEndpoint
}
