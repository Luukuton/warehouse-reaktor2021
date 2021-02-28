import React from "react"
import PropTypes from "prop-types"
import VirtualScroller from "virtual-scroller/react"
import styles from '../styles/Table.module.scss'

function Products({ products }) {
    return <VirtualScroller 
        items={products} 
        itemComponent={Product} 
    />
}
  
const product = PropTypes.shape({
    name: PropTypes.string.isRequired,
    color: PropTypes.array.isRequired,
    price: PropTypes.number.isRequired,
    manufacturer: PropTypes.string.isRequired,
    id: PropTypes.string.isRequired,
    status: PropTypes.string.isRequired
})

Products.propTypes = {
    products: PropTypes.arrayOf(product).isRequired
}

function Product({ children: product }) {
    const {
    id,
    name,
    color,
    price,
    manufacturer,
    status
    } = product

    return <div key={id} className={styles.rTableRow}>
        <div className={`${styles.rTableCell} ${styles.item}`}><b>{name}</b> <br /> <i>{id}</i></div>
        <div className={`${styles.rTableCell} ${styles.item}`}>{color.join(", ")}</div>
        <div className={`${styles.rTableCell} ${styles.item}`}>{price}</div>
        <div className={`${styles.rTableCell} ${styles.item}`}>{manufacturer}</div>
        <div className={`${styles.rTableCell} ${styles.item}`}>{status}</div>
    </div>
}

Product.propTypes = {
    children: product.isRequired
}

export default Products
