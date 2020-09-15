let previousPageUrl = null

if (process.ENV === 'production') {
  window._paq = window._paq || []

  const url = 'https://analytics.malheatmap.com/'
  const trackerUrl = `${url}matomo.php`
  const jsUrl = `${url}matomo.js`

  // Configure Matomo analytics
  window._paq.push(['trackPageView'])
  window._paq.push(['enableLinkTracking'])

  // Load script from Matomo
  window._paq.push(['setTrackerUrl', trackerUrl])
  window._paq.push(['setSiteId', '1'])

  const script = document.createElement('script')
  const firstScript = document.getElementsByTagName('script')[0]
  script.type = 'text/javascript'
  script.id = 'matomo-js'
  script.async = true
  script.src = jsUrl
  firstScript.parentNode.insertBefore(script, firstScript)

  document.addEventListener('turbolinks:load', (event) => {
    if (previousPageUrl) {
      window._paq.push(['setReferrerUrl', previousPageUrl])
      window._paq.push(['setCustomUrl', window.location.href])
      window._paq.push(['setDocumentTitle', document.title])
      if (event.data && event.data.timing) {
        window._paq.push(['setGenerationTimeMs', event.data.timing.visitEnd - event.data.timing.visitStart]);
      }
      window._paq.push(['trackPageView'])
    }
    previousPageUrl = window.location.href
  })
}
