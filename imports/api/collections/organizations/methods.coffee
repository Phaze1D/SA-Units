{ Meteor } = require 'meteor/meteor'
{ ValidatedMethod }  = require  'meteor/mdg:validated-method'
{ SimpleSchema }  = require  'meteor/aldeed:simple-schema'
{ DDPRateLimiter }  = require  'meteor/ddp-rate-limiter'

OrganizationModule = require './organizations.coffee'


###

  Methods checklist
    Make sure user is logged in
    Make sure user belongs to organization of updated model
    Make sure user has permission to update model
    Validate the user input

###

# Create Mixin
isLoggedIn = (userId) ->
  unless userId?
    throw new Meteor.Error 'notLoggedIn', 'Must be logged in'
  return true


# Insert
module.exports.insert = new ValidatedMethod
  name: 'organization.insert'
  validate: (organization_doc) ->
    if OrganizationModule.Organizations.findOne(name: organization_doc.name)?
      throw new Meteor.Error 'nameNotUnqiue', 'name must be unqiue'
    OrganizationModule.Organizations.simpleSchema().validate(organization_doc)

  run: (organization_doc) ->
    isLoggedIn(@userId)
    OrganizationModule.Organizations.insert organization_doc
