package main

import (
	"errors"
	"fmt"
	"github.com/jfrog/jfrog-cli/plugins/core"
	"strconv"
	"strings"
)

func main() {
	core.JfrogPluginMain(getApp())
}

func getApp() core.App {
	app := core.App{}
	app.Name = "plugin-template"
	app.Usage = "See the plugin documentation for more instructions."
	app.Version = "0.1.0"
	app.Commands = getCommands()
	return app
}

func getCommands() []core.Command {
	return []core.Command{
		{
			Name:        "hello",
			Description: "Says Hello.",
			Aliases:     []string{"hi"},
			Arguments: []core.Argument{
				{
					Name:        "addressee",
					Description: "The name of the addressee you would like to greet.",
				},
			},
			Flags: []core.StringFlag{
				{
					Name:  "shout",
					Usage: "Makes output all uppercase.",
				},
			},
			Action: func(c *core.Context) error {
				return helloCmd(c)
			},
		},
	}
}

func helloCmd(c *core.Context) error {
	if len(c.Arguments) != 1 {
		return errors.New("Wrong number of arguments. Expected: 1," + "Received: " + strconv.Itoa(len(c.Arguments))) //todo add command to context
	}
	greet := "Hello " + c.Arguments[0] + "!"
	if val, ok := c.Flags["shout"]; ok {
		if val == "true" {
			greet = strings.ToUpper(greet)
		}
	}
	fmt.Println(greet)
	return nil
}
