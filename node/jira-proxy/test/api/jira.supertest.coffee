Supertest = require '../../src/_test-utils/Supertest'
cheerio   = require 'cheerio'
Data      = require '../../../jira-issues/src/data'

describe 'api | supertest | Jira', ->
  supertest = null
  data      = null

  request = (path, callback)->
    supertest.request "/api/jira/#{path}", callback

  before ->
    data      = new Data()
    supertest = new Supertest()

  it 'jira/issue-delete/RISK-25', ->
    supertest.request '/api/jira/issue-delete/RISK-25', (data)->
      data.assert_Is status:true

  it 'fields/schema', ->
    request 'fields/schema', (data)->
      data.size().assert_In_Between 300,500
      data[0].id.assert_Is 'resolution'

  it 'fields/schema?pretty', ->
    request 'fields/schema?pretty', (data)->
      data.assert_Contains("<pre>")
          .assert_Contains('"id": "resolution"')

  it 'jira/issue-raw/RISK-1', ->
    supertest.request '/api/jira/issue-raw/RISK-1', (data)->
      data.assert_Is_Object()
      data.key.assert_Is 'RISK-1'

  it 'jira/issue-raw/RISK-1?pretty', ->
    supertest.request '/api/jira/issue-raw/RISK-1?pretty', (data)->
      data.assert_Is_String()
      data.assert_Contains '"key": "RISK-1"'

  xit 'jira/issue-raw/RISK-25 (force fetch)', ->
    id = "RisK-25"
    data.delete_Raw_Data id
    supertest.request "/api/jira/issue-raw/#{id}?pretty" , (data)->
      data.assert_Is_String()
      data.assert_Contains id.upper()


  it 'jira/issue/RISK-1', ->
    supertest.request '/api/jira/issue/RISK-1', (data)->
      data.assert_Is_Object()
      data.key.assert_Is 'RISK-1'

  it 'jira/issue/RISK-1', ->
    supertest.request '/api/jira/issue/RISK-1?pretty', (data)->
      data.assert_Is_String()
      data.assert_Contains '"key": "RISK-1"'

  it 'jira/issues/ids', ->
    supertest.request '/api/jira/issues/ids', (data)->
      data.assert_Contains ['RISK-1']

  it 'jira/issues/files', ->
    supertest.request '/api/jira/issues/files', (data)->
      data["RISK-1"].assert_Is '/RISK/RISK/RISK-1.json'


  # BUGS

  it 'TypeError: Cannot read property json_Pretty of null',->
    request 'issue/GDPR-aaaa?pretty', (data)->
      data.assert_Contains 'not found'

