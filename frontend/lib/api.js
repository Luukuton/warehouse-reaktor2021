export function getAPIURL(path = "") {
    return `${
      process.env.INTERNAL_API_URL
    }${path}`
  }

  export async function fetchAPI(path) {
    const requestUrl = getAPIURL(path)
    const response = await fetch(requestUrl)
    return await response.json()
  }
  