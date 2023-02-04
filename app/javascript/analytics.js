// Script for sending analytics events to a self hosted matomo app

window._paq = window._paq || [];

const analyticsUrlTag = document.querySelector("meta[name='analytics-site-url']")
const analyticsIdTag = document.querySelector("meta[name='analytics-site-id']")

if (analyticsUrlTag && analyticsUrlTag.content && analyticsIdTag && analyticsIdTag.content) {
  window._paq.push(['trackPageView'])
  window._paq.push(['enableLinkTracking'])
  window._paq.push(['setTrackerUrl', `${analyticsUrlTag.content}/matomo.php`])
  window._paq.push(['setSiteId', analyticsIdTag.content])

  const script = document.createElement('script')
  const firstScript = document.getElementsByTagName('script')[0]
  script.type = 'text/javascript'
  script.id = 'matomo-js'
  script.async = true
  script.src = `${analyticsUrlTag.content}/matomo.js`
  firstScript.parentNode.insertBefore(script, firstScript)

  let previousPageUrl = null

  document.addEventListener('turbo:load', function (event) {
    if (previousPageUrl) {
      window._paq.push(['setReferrerUrl', previousPageUrl])
      window._paq.push(['setCustomUrl', window.location.href])
      window._paq.push(['setDocumentTitle', document.title])
      if (event.data && event.data.timing) {
        window._paq.push(['setGenerationTimeMs', event.data.timing.visitEnd - event.data.timing.visitStart])
      }
      window._paq.push(['trackPageView'])
    }
    previousPageUrl = window.location.href
  })
}
