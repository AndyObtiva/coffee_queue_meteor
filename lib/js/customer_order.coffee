@CustomerOrder = class CustomerOrder
  constructor: (order) ->
    $.extend(this, order)

  # Static customer order service methods
  @customerOrders : (orders=null) ->
    orders = Orders.find().fetch() unless orders
    _.map(orders, (order) -> new CustomerOrder(order))
  @ordersInProgress : ->
    _.filter(@customerOrders(), (order) -> order.waiting())
  @noOrdersInProgress : ->
    @ordersInProgress().length == 0
  @readyOrders : ->
    _.filter(@customerOrders(), (order) -> order.ready())
  @fulfilledOrders : ->
    _.filter(@customerOrders(), (order) -> order.fulfilled())

  # Customer order individual instance methods
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
