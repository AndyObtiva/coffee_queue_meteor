// Task component - represents a single todo item
OrderView = React.createClass({
  propTypes: {
    // This component gets the task to display through a React prop.
    // We can use propTypes to indicate it is required
    order: React.PropTypes.object.isRequired
  },
  render() {
    return (
      <tr>
        <td>
          {this.props.order.name}
        </td>
        <td>
          {this.props.order.product.name} {this.props.order.productOption.name}
        </td>
      </tr>
    );
  }
});
