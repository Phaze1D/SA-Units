{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
YieldModule = require '../yields/yields.coffee'
EventModule = require '../events/events.coffee'
SellModule = require '../sells/sells.coffee'
ExpenseModule = require '../expenses/expenses.coffee'


class UnitsCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    super(selector, callback)


UnitSchema =
  new SimpleSchema([

    name:
      type: String
      label: 'unit_name'
      index: true
      max: 64

    description:
      type: String
      label: 'description'
      optional: true
      max: 256

    amount:
      type: Number
      label: 'amount'
      min: 0
      defaultValue: 0

    unit_id:
      type: String
      index: true
      sparse: true
      optional: true

  , CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Units = exports.Units = new UnitsCollection('units')
Units.attachSchema UnitSchema

Units.deny
    insert: ->
      yes
    update: ->
      yes
    remove: ->
      yes


Units.helpers

  parent: ->
    Units.findOne { _id: @unit_id }

  children: ->
    Units.find { unit_id: @_id }

  yields: ->
    YieldModule.Yields.find { unit_id: @_id }

  sells: ->
    SellModule.Sells.find { 'sell_details.unit_id': @_id} 

  events: ->
    EventModule.Events.find { for_id: @_id }

  expenses: ->
    ExpenseModule.Expenses.find { unit_id: @_id }

  organization: ->
    OrganizationModule.Organizations.findOne { _id: @organization_id }

  created_by: ->
    Meteor.users.findOne { _id: @user_id}

if Meteor.isServer
  multikeys =
    name: 1
    organization_id: 1

  Units.rawCollection().createIndex multikeys, unique: true, (error) ->

# Unit depends on unit id. If parent unit is delete
#                         Option 1: Set unit_id to parents parent
#                         Option 2: Make unit_id null
