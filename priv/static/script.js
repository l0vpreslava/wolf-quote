window.onload = () => {
    let button = document.querySelector(".reload-button")
    console.log(button)
    button.onclick = () => { window.location.reload() };
};
