package main

import (
	"errors"
	"fmt"
	"github.com/jfrog/jfrog-cli/jfrogcliplugins"
	"strconv"
	"strings"
)

func main() {
	jfrogcliplugins.JfrogPluginMain(getApp())
}

func getApp() jfrogcliplugins.App {
	app := jfrogcliplugins.App{}
	app.Name = "plugintemplate"
	app.Usage = "See the plugin documentation for more instructions."
	app.Version = "0.1.0"
	app.Commands = getCommands()
	return app
}

func getCommands() []jfrogcliplugins.Command {
	return []jfrogcliplugins.Command{
		{
			Name:        "hello",
			Description: "Says Hello.",
			Aliases:     []string{"hi"},
			Arguments: []jfrogcliplugins.Argument{
				{
					Name:        "addressee",
					Description: "The name of the addressee you would like to greet.",
				},
			},
			Flags: []jfrogcliplugins.StringFlag{
				{
					Name:  "shout",
					Usage: "Makes output all uppercase.",
				},
			},
			Action: func(c *jfrogcliplugins.Context) error {
				return helloCmd(c)
			},
		},
	}
}

func helloCmd(c *jfrogcliplugins.Context) error {
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
