{ Meteor } = require 'meteor/meteor'
{ Template } = require 'meteor/templating'
{ Accounts } = require 'meteor/accounts-base'
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ ReactiveVar } = require 'meteor/reactive-var'


{ Organizations } = require '../../../api/collections/organizations/organizations.coffee'


require './selector.html'


Template.ExpensesSelector.onCreated ->
  organ_id = FlowRouter.getParam('organization_id')

  @subCallback =
    onStop: (err) ->
      console.log "selector ing stop #{err}"
    onReady: () ->

  @autorun =>
    new SimpleSchema(
      select:
        type: Function
    ).validate(@data)
    @subscribe 'expenses', organ_id, 'organization', organ_id, @subCallback


Template.ExpensesSelector.helpers
  expenses:  ->
    organization = Organizations.findOne(FlowRouter.getParam('organization_id'))
    return false if organization.expenses().count() <= 0
    organization.expenses()


Template.ExpensesSelector.events
  'click .js-expense-select': (event, instance) ->
    id = $(event.target).attr 'data-id'
    instance.data.select id
