import React from "react"
import Link from "next/link"

import styles from '../styles/Main.module.scss'
import categories from "../lib/categories"

const Nav = () => {
  return <header className={styles.header}>
    <Link as={`/`} href="/">🏠 Home</Link>
    {categories[1].map((category) => {
      return <Link key={category} as={`/category/${category}`} href="/category/[slug]">
        <a>{category.charAt(0).toUpperCase() + category.slice(1)}</a>
      </Link>
    })}
  </header>
  
}

export default Nav
