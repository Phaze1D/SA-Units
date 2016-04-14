{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

{ ContactSchema } = require '../contact_info.coffee'
{ TimestampSchema } = require '../timestamps.coffee'
{ CreateByUserSchema } = require '../created_by_user.coffee'
{ BelongsOrganizationSchema } = require '../belong_organization.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
ExpenseModule = require '../expenses/expenses.coffee'


class ProvidersCollection extends Mongo.Collection
  insert: (doc, callback) ->
    super(doc, callback)

  update: (selector, modifier, options, callback) ->
    super(selector, modifier, options, callback)

  remove: (selector, callback) ->
    ###
      Can just be delete normally ask user are you sure
    ###
    super(selector, callback)

ProviderSchema =
  new SimpleSchema([
      first_name:
        type: String
        label: "first_name"
        max: 64

      last_name:
        type: String
        label: "last_name"
        optional: true
        max: 64

      company:
        type: String
        label: "company"
        optional: true
        max: 64

  , ContactSchema, CreateByUserSchema, BelongsOrganizationSchema, TimestampSchema])

Providers = exports.Providers = new ProvidersCollection "providers"
Providers.attachSchema ProviderSchema

Providers.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Providers.helpers
    expanses: ->
      ExpenseModule.Expenses.find { provider_id: @_id}

    organization: ->
      OrganizationModule.Organizations.findOne { _id: @organization_id }

    created_by: ->
      Meteor.users.findOne { _id: @created_user_id}

    updated_by: ->
      Meteor.users.findOne { _id: @updated_user_id}

if Meteor.isServer
  multikeys =
    email: 1
    organization_id: 1

  Providers.rawCollection().createIndex multikeys, unique: true, (error) ->
    # console.log error

# * depends on organization_id. If organization is deleted then all * of that organization will be deleted
# * depends on user_id. If user is delete then user_id will change to the current user or owner
