import '../../assets/stylesheets/users.scss'

document.addEventListener('turbolinks:load', () => {
  document.querySelector('button.copy-signature').onclick = () => {
    const input = document.querySelector('input.signature-input')
    input.select()

    document.execCommand('copy')
  }
})
