{ Mongo } = require 'meteor/mongo'
{ SimpleSchema } = require 'meteor/aldeed:simple-schema'
{ Meteor } = require 'meteor/meteor'

ContactModule = require '../../shared/contact_info.coffee'
{ TimestampSchema } = require '../../shared/timestamps.coffee'
{ BelongsOrganizationSchema } = require '../../shared/belong_organization.coffee'
{ CreateByUserSchema } = require '../../shared/created_by_user.coffee'

OrganizationModule = require '../organizations/organizations.coffee'
CustomerModule = require '../customers/customers.coffee'
EventModule = require '../events/events.coffee'
ExpenseModule = require '../expenses/expenses.coffee'
InventoryModule = require '../inventories/inventories.coffee'
ProductModule = require '../products/products.coffee'
IngredientModule = require '../ingredients/ingredients.coffee'
ProviderModule = require '../providers/providers.coffee'
SellModule = require '../sells/sells.coffee'
UnitModule = require '../units/units.coffee'
YieldModule = require '../yields/yields.coffee'


UserProfileSchema = exports.UserProfileSchema =
  new SimpleSchema([
    first_name:
      type: String
      label: 'first_name'
      max: 64
      optional: true

    last_name:
      type: String
      label: 'last_name'
      max: 64
      optional: true

    date_of_birth:
      type: Date
      label: 'date_of_birth'
      optional: true

    notes:
      type: String
      label: 'notes'
      optional: true

    user_avatar_url:
      type: String
      label: 'avatar'
      regEx: SimpleSchema.RegEx.Url
      optional: true

    addresses:
      type: [ContactModule.AddressSchema]
      optional: true
      defaultValue: []
      maxCount: 5

    telephones:
      type: [ContactModule.TelephoneSchema]
      optional: true
      defaultValue: []
      maxCount: 5
   ])

UserSchema =
  new SimpleSchema([

    _id:
      type: String
      optional: true

    username:
      type: String
      label: 'username'
      optional: true

    emails:
        type: Array
        min: 1

    "emails.$":
        type: Object

    "emails.$.address":
        type: String,
        regEx: SimpleSchema.RegEx.Email

    "emails.$.verified":
        type: Boolean
        optional: true
        defaultValue: false

    profile:
      type: UserProfileSchema
      optional: true

    services:
        type: Object
        optional: true
        blackbox: true

  , CreateByUserSchema, TimestampSchema])

Meteor.users.attachSchema UserSchema

Meteor.users.deny
  insert: ->
    yes
  update: ->
    yes
  remove: ->
    yes

Meteor.users.helpers
  customers: ->
    CustomerModule.Customers.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  events: ->
    EventModule.Events.find { $or:  [ created_user_id: @_id, updated_user_id: @_id]}, sort: created_at: -1
  expenses: ->
    ExpenseModule.Expenses.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  inventories: ->
    InventoryModule.Inventories.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  ingredients: ->
    IngredientModule.Ingredients.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  products: ->
    ProductModule.Products.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  providers: ->
    ProviderModule.Providers.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  sells: ->
    SellModule.Sells.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  units: ->
    UnitModule.Units.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  users: ->
    Meteor.users.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  yields: ->
    YieldModule.Yields.find { $or:  [ created_user_id: @_id, updated_user_id: @_id] }, sort: created_at: -1
  organizations: ->
    OrganizationModule.Organizations.find { ousers: $elemMatch: user_id: @_id } # careful
