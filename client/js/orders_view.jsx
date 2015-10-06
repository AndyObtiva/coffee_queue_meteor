// Task component - represents a single todo item
OrdersView = React.createClass({
  propTypes: {
    // This component gets the task to display through a React prop.
    // We can use propTypes to indicate it is required
    orders: React.PropTypes.object.isRequired
  },
  renderOrders() {
    // console.log(Orders);
    // var orders = _.pairs(Orders.find().collection._docs._map).map((order) => {return order[1]});
    // console.log(orders);
    return this.props.orders.map((order) => {
      return <OrderView key={order._id} order={order} />;
    });
  },
  render() {
    return (
      <table>
      {this.renderOrders()}
      </table>
    );
  }
});
