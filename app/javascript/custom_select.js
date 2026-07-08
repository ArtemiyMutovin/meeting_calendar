// Кастомный выпадающий список времени.
// Одно делегированное событие на document — работает для любого числа полей
// и не зависит от порядка загрузки контроллеров.
document.addEventListener("click", (event) => {
  const trigger = event.target.closest(".cselect__trigger")
  const option = event.target.closest(".cselect__option")

  // Закрываем все открытые списки, которых не касается текущий клик
  document.querySelectorAll(".cselect.is-open").forEach((el) => {
    if (!el.contains(event.target)) el.classList.remove("is-open")
  })

  if (trigger) {
    trigger.closest(".cselect").classList.toggle("is-open")
    return
  }

  if (option) {
    const cselect = option.closest(".cselect")
    cselect.querySelector(".cselect__input").value = option.dataset.value
    cselect.querySelector(".cselect__trigger").textContent = option.textContent
    cselect.querySelectorAll(".cselect__option").forEach((o) => {
      o.classList.toggle("is-selected", o === option)
    })
    cselect.classList.remove("is-open")
  }
})
