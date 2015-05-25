@Orders = new Meteor.Collection("orders")
@Products = new Meteor.Collection("products")
@ProductOptions = new Meteor.Collection("productOptions")
@Baristas = Meteor.users

@CustomerOrder = class CustomerOrder
  constructor: (order) ->
    $.extend(this, order)

  waiting: ->
    !@state

  ready: ->
    @state == 'ready'

  served: ->
    @state == 'served'

  fulfilled: ->
    !!@fulfilledAt

  fulfillmentTime: ->
    time = @fulfilledAt - @createdAt
    if (time == NaN) then Infinity else time

