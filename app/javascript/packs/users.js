import '../../assets/stylesheets/users.scss'

document.addEventListener('turbolinks:load', () => {
  const copyButton = document.querySelector('.copy-signature')

  if (!copyButton) return

  copyButton.onclick = () => {
    const input = document.querySelector('input.signature-input')
    input.select()

    document.execCommand('copy')
    window._paq.push(['trackEvent', 'User Profile', 'Signature Copied'])
  }
})
