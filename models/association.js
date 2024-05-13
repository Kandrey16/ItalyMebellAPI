const sequelize = require('../db')
const { DataTypes, DATE} = require('sequelize')

const Attribute_group = require('./attribute_group_model')
const Attribute = require('./attribute_model')
const Cart = require('./cart_model')
const Cart_product = require('./cart_product_model')
const Category = require('./category_model')
const Collection = require('./collection_model')
const Image_comment = require('./image_comment_model')
const Order_address = require('./order_address_model')
const Order_product = require('./order_product_model')
const Order_delivery = require('./order_delivery_model')
const Order_status = require('./order_status_model')
const Orders = require('./orders_model')
const Product_comment = require('./product_comment_model')
const Product_image = require('./product_image_model')
const Product = require('./product_model')
const Specification = require('./specification_model')
const User_profile = require('./user_profile_model')
const Payment_method = require('./payment_method_model')

//attribute
Attribute_group.hasMany(Attribute, { foreignKey: 'id_attribute_group' });
Attribute.belongsTo(Attribute_group, { foreignKey: 'id_attribute_group' });

//product_image
Product.hasMany(Product_image, { foreignKey: 'id_product' });
Product_image.belongsTo(Product, { foreignKey: 'id_product' });

//image_comment
Product_comment.hasMany(Image_comment, { foreignKey: 'id_product_comment' });
Image_comment.belongsTo(Product_comment, { foreignKey: 'id_product_comment' });

//Category
Category.hasMany(Product, {foreignKey: 'id_category'});
Product.belongsTo(Category, {foreignKey: 'id_category'});

//Collection
Collection.hasMany(Product, {foreignKey:'id_collection'})
Product.belongsTo(Collection, {foreignKey: 'id_collection'})

//Payment Method
Payment_method.hasMany(Orders, {foreignKey: 'id_payment_method'});
Orders.belongsTo(Payment_method, {foreignKey: 'id_payment_method'})

//Order delivery
Order_delivery.hasMany(Orders, {foreignKey: 'id_order_delivery'});
Orders.belongsTo(Order_delivery, {foreignKey: 'id_order_delivery'})

//specification
//attribute
//attribute
Specification.belongsTo(Attribute, { foreignKey: 'id_attribute', as: 'attribute' });
Attribute.hasMany(Specification, { foreignKey: 'id_attribute', as: 'specifications' });
//product
Specification.belongsTo(Product, { foreignKey: 'id_product', as: 'product' });
Product.hasMany(Specification, { foreignKey: 'id_product', as: 'specifications' });

//order_address
User_profile.hasMany(Order_address, { foreignKey: 'email_user'});
Order_address.belongsTo(User_profile, { foreignKey: 'email_user'});

//Cart
User_profile.hasOne(Cart, {foreignKey: 'email_user'});
Cart.belongsTo(User_profile, {foreignKey: 'email_user'});

Cart_product.belongsTo(Cart, {foreignKey: 'id_cart'});
Cart.hasMany(Cart_product, {foreignKey: 'id_cart'});

Cart_product.belongsTo(Product, {foreignKey: 'id_product'});
Product.hasMany(Cart_product, {foreignKey: 'id_product'});

//order
Order_address.hasMany(Orders, { foreignKey: 'id_order_address' });
Orders.belongsTo(Order_address, { foreignKey: 'id_order_address' });

Order_product.belongsTo(Orders, { foreignKey: 'id_order', as: 'order' });
Orders.hasMany(Order_product, { foreignKey: 'id_order', as: 'order_product' });

Orders.belongsTo(Payment_method, { foreignKey: 'id_payment_method' });
Payment_method.hasMany(Orders, { foreignKey: 'id_payment_method' });

Orders.belongsTo(Order_status, {foreignKey: 'id_order_status'});
Order_status.hasMany(Orders, {foreignKey: 'id_order_status'});

// Связь Cart_product с Order_product
Product.hasMany(Order_product, { foreignKey: 'id_product' });
Order_product.belongsTo(Product, { foreignKey: 'id_product' });

Product_comment.belongsTo(Product, { foreignKey: 'id_product' });
Product.hasMany(Product_comment, { foreignKey: 'id_product' });

Product_comment.belongsTo(User_profile, { foreignKey: 'email_user'});
User_profile.hasMany(Product_comment, { foreignKey: 'email_user' });

//Attribute Category МКМ
Category.belongsToMany(Attribute_group, {
    through: 'category_attribute_groups',
    foreignKey: 'id_category',
    otherKey: 'id_attribute_group'
});
Attribute_group.belongsToMany(Category, {
    through: 'category_attribute_groups',
    foreignKey: 'id_attribute_group',
    otherKey: 'id_category'
});


module.exports = {
    User_profile,
    Attribute_group,
    Attribute,
    Cart,
    Cart_product,
    Category,
    Collection,
    Product,
    Specification,
    Payment_method,
    Product_image,
    Product_comment,
    Image_comment,
    Order_address,
    Orders,
    Order_product,
    Order_delivery,
    Order_status,
}