import Head from 'next/head'
import React from "react"
import Layout from "../components/layout"

import styles from '../styles/Main.module.scss'

const Home = () => {
  return <React.Fragment>
    <Head>
      <title>Warehouse</title>
      <link rel="icon" href="/favicon.ico" />
    </Head>
    <Layout>
      <h1 className={styles.title}>
        Warehouse
      </h1>

      <p className={styles.description}>
        Reaktor Developer (summer 2021) pre-assignment. 
        Source code <a href="https://github.com/Luukuton/warehouse-reaktor2021">here</a>.
      </p>

    </Layout>
  </React.Fragment>
  
}

export default Home
