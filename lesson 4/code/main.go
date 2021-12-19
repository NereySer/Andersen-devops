package main

import (
    "fmt"
    "regexp"
    "github.com/Syfaro/telegram-bot-api"
    "github.com/joho/godotenv"
    "os"
    "reflect"
    "time"
    "os/exec"
    "sort"
    "strconv"
//    "strings"
//    "log"
)

func telegramBot() {

    bot, err := tgbotapi.NewBotAPI(os.Getenv("API_TOKEN"))
    if err != nil {
        panic(err)
    }

    var rCommandStart = regexp.MustCompile("^/start$")
    var rCommandHelp = regexp.MustCompile("^/help$")
    var rCommandGit = regexp.MustCompile("^/git$")
    var rCommandTasks = regexp.MustCompile("^/tasks$")
    var rCommandTask = regexp.MustCompile("^/task([0-9]*)$")

    var rLesson = regexp.MustCompile(os.Getenv("GIT_LESSONS_REGEXP"))

    u := tgbotapi.NewUpdate(0)
    u.Timeout = 60

    updates := bot.GetUpdatesChan(u)

    for update := range updates {
        if update.Message == nil {
            continue
        }

        if reflect.TypeOf(update.Message.Text).Kind() == reflect.String && update.Message.Text != "" {

            switch {
            case rCommandStart.MatchString(update.Message.Text):

                msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Hello. Here you can get information about lessons in git. Use /help to get more information.")
                bot.Send(msg)

            case rCommandHelp.MatchString(update.Message.Text):

                msg := tgbotapi.NewMessage(update.Message.Chat.ID, `
/git - return link to git
/tasks - return a list of completed tasks for lessons
/task# where # is number of the task - return link to the folder with completed task
                    `)
                bot.Send(msg)

            case rCommandGit.MatchString(update.Message.Text):

                msg := tgbotapi.NewMessage(update.Message.Chat.ID, os.Getenv("GIT_URL"))
                bot.Send(msg)

            case rCommandTasks.MatchString(update.Message.Text):

                stdout, err := exec.Command("svn", "list", os.Getenv("GIT_LESSONS")).Output()

                if err != nil {
                    msg := tgbotapi.NewMessage(update.Message.Chat.ID, "There is error occured while obtaining tasks list: " + err.Error())
                    bot.Send(msg)
                } else {
                    result := rLesson.FindAllStringSubmatch(string(stdout), -1)

                    if result != nil {
                        msgtxt := "Here is the list of the completed tasks with commands to get the link to it's folder:\n"

                        sort.Slice(result, func(i, j int) bool {
                            var r1, r2 int
                            var err error

                            if r1, err = strconv.Atoi(result[i][2]); err != nil { return true }
                            if r2, err = strconv.Atoi(result[j][2]); err != nil { return false }

                            return r1 < r2
                        })

                        for _, element := range result {
                            msgtxt += element[1]+" /task"+element[2]+"\n"
                        }

                        msg := tgbotapi.NewMessage(update.Message.Chat.ID, msgtxt)
                        bot.Send(msg)
                    } else {
                        msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Sorry, there is no completed tasks available")
                        bot.Send(msg)
                    }
                }



            case rCommandTask.MatchString(update.Message.Text):

                result := rCommandTask.FindStringSubmatch(update.Message.Text)

                if result[1] == "" {
                    msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Please specify task number. Use /help for more information.")

                    bot.Send(msg)
                } else {
                    msg := tgbotapi.NewMessage(update.Message.Chat.ID, fmt.Sprintf(os.Getenv("GIT_LESSON_FOLDER_FMT"), result[1]))

                    bot.Send(msg)
                }

            default:
                msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Wrong command. Use /help to get more information.")
                bot.Send(msg)

            }
        } else {

            msg := tgbotapi.NewMessage(update.Message.Chat.ID, "Please use valid command. Use /help to get more information.")
            bot.Send(msg)
        }
    }
}

func main() {

    err := godotenv.Load(".env")
    if err != nil {
        panic(err)
    }

    err = godotenv.Load("../tlg_bot_cred.env")
    if err != nil {
        panic(err)
    }

    time.Sleep(1 * time.Second)

    telegramBot()
}
