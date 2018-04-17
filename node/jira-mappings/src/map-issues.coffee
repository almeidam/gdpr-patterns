Issues    = require '../src/util/issues'

config = # move this to spearate file
  ignore_fields:   [ "Σ Progress" , "Attachment", "Classement", "Classement (Obsolete)", "Global Rank (Obsolete)",
                     "Global Rank", "Moonpig IOS Definition of Ready Verified?","Severity Moonpig Mobile","Frequency","Regression",
                     "Fix Version/s", "Progress", "Request participants","Reporter", "Sub-Tasks", "Time Tracking", "Affects Version/s", "Votes", "Watchers",
                     "Log Work", "Work Ratio",
                     "Component/s", "Description", "Labels"]

class Map_Issues
  constructor: ->
    @.issues = new Issues()

  issue: (id)->
    fields_Schema = @.issues.fields_Schema()

    raw_Issue = @.issues.issue_Raw_Data(id)

    if raw_Issue
      result = id : id      # add this extra mapping so that it will be needed on import (later)

      for key,value of raw_Issue
        if fields_Schema[key]
          field_Name         = fields_Schema[key].name
          field_Type         = fields_Schema[key].schema_Type_Name

          if config.ignore_fields.contains field_Name
            console.log field_Name
            continue

          result[field_Name] = @.get_Data_By_Type field_Name, field_Type, value
      return result

    return null

  get_LinkedIssues: (raw_Data)->
    result = []
    for item in raw_Data
      inward = raw_Data.raw_Data
      if item.outwardIssue
        result.add { key: item.outwardIssue.key , type: item.type.outward, direction: 'outward'}
      if item.inwardIssue
        result.add { key: item.inwardIssue.key  , type: item.type.inward, direction: 'outward'}

    return result

  get_Data_By_Type: (field_Name, field_Type, raw_Data)->
    parser =
      any            : (raw)-> return raw
      datetime       : (raw)-> new Date(raw_Data).toDateString()
      issuetype      : (raw)-> return raw.name
      number         : (raw)-> return raw
      option         : (raw)-> return raw.value
      priority       : (raw)-> return raw.name
      progress       : (raw)-> return raw.progress
      project        : (raw)-> return raw.name
      status         : (raw)-> return raw.name
      string         : (raw)-> return raw
      timetracking   : (raw)-> return ''
      user           : (raw)-> return raw.name
      votes          : (raw)-> return raw.votes
      watches        : (raw)-> return raw.watchCount
      array          : (raw)->
        result = []
        for item in raw_Data
          result.push item.value
        return result
      comments: (raw)->
        result = []
        for item in raw_Data.comments
          result.push item.body
        return result
      'comments-page': (raw)-> return ''            # ignored

    if field_Name is 'Linked Issues'
      return @.get_LinkedIssues raw_Data

    if parser[field_Type]
      return parser[field_Type](raw_Data)

    console.log "[get_Data_By_Type] no parser for #{field_Type}"
    #console.log field_Type
    #console.log raw_Data
    return null


module.exports = Map_Issues