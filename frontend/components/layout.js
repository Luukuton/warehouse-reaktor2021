import React from "react"
import Nav from "./nav"
import Footer from "./footer"
import ThemeToggle from "./themetoggle"

import styles from '../styles/Main.module.scss'

const Layout = ({ children, categories }) => {
  return <div className={styles.container}>
    <main className={styles.main}>
      <ThemeToggle />
      <Nav categories={categories} />
      {children}
      <Footer />
    </main>
  </div>
  
}

export default Layout
