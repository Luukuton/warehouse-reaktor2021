import { fetchAPI } from "../../lib/api"
import React from "react"
import Product from "../../components/product"
import Layout from "../../components/layout"

import styles from '../../styles/Table.module.scss'
import categories from "../../lib/categories"

const Category = ({ category }) => {
  const title = category[1][0].type.charAt(0).toUpperCase() + category[1][0].type.slice(1)
  return <Layout>
    <h1 className={styles.title}>{title}</h1>
    <p className={styles.updated_at}>Updated at {category[0].updated_at}</p>
    <div className={styles.rTableRow}>
      <div className={styles.rTableHead}><b>NAME</b> & ID</div>
      <div className={styles.rTableHead}>COLORS</div>
      <div className={styles.rTableHead}>PRICE</div>
      <div className={styles.rTableHead}>MANUF.</div>
      <div className={styles.rTableHead}>STATUS</div>
    </div>
    <div className={styles.rTable}>
      <Product products={category[1]} />
    </div>
  </Layout>
}

export async function getStaticPaths() {
  return {
    paths: categories[0], 
    fallback: false,
  }
}

export async function getStaticProps({ params }) {
  const category = await fetchAPI(`/${params.slug}`)

  return {
    props: { category: category },
    revalidate: 1,
  }
}

export default Category
