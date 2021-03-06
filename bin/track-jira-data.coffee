#!/usr/bin/env coffee
require 'fluentnode'

Track_Queries   = require '../node/jira-issues/src/jira/track-queries'
Mappings_Create = require '../node/jira-mappings/src/create.coffee'
Admin_Functions = require '../node/jira-proxy/src/api/admin.coffee'
Save_Data = require '../node/jira-issues/src/jira/save-data.coffee'
CONFIG = require(process.argv.slice(2)[0])
exec = require('child_process').exec

git_url = process.env.GIT_HTTP_Url || CONFIG.jira_data_git

track_Queries   = new Track_Queries()
mappings_Create = new Mappings_Create()
admin_functions = new Admin_Functions()
save_data = new Save_Data()

delay         = 30 * 1000

clone_GIT = ->
  exec_command = 'git clone ' + git_url + ' data'
  new Promise (resolve) ->
    exec exec_command, (error, stdout, stderr) ->
      if stdout
        console.log 'GIT CLONED'
        #resolve(99)
      if error
        console.error 'ERROR ', stderr
        #resolve(99)
      resolve(99)

pull_from_GIT = ->
  new Promise (resolve) ->
    exec 'cd data; git pull origin master; cd ..', (error, stdout, stderr) ->
      if stdout
        console.log 'GIT PULLED'
        #resolve(99)
      if error
        console.error 'ERROR ', stderr
      resolve(99)

push_to_GIT = ->
  exec_command = 'cd data; git add --all; git commit -m "' + new Date().getTime() + '"; git push; cd ..'
  new Promise (resolve) ->
    exec exec_command, (error, stdout, stderr) ->
      if stdout
        console.log 'GIT PUSHED'
        #resolve(99)
      if error
        console.error 'ERROR ', stderr
      resolve(99)

update_Mappings = (result)->
  if result.size() > 0
    console.log("Size: "  +result.size())
    await mappings_Create.all()
    console.log("pushing....")
    await push_to_GIT()
    console.log("pulling....")
    await pull_from_GIT()

update_data_from_JIRA = ->
  new Promise (resolve) ->
    track_Queries.update_by_jql CONFIG.jql, await update_Mappings
    resolve(99)

init = ->
  console.log("START")
  await clone_GIT()
  await pull_from_GIT()  
  setInterval  await update_data_from_JIRA, delay

init()