---
layout: default
title: Recherche de Machines
icon: fas fa-server
order: 1
permalink: /machines/
---

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<div class="main-content">
  <div class="machines-header">
    <h1>
      <img src="https://i.ibb.co/4nqKzbkW/Hackthebox-cube.png" alt="HackTheBox Logo" width="50">
      <img src="https://i.ibb.co/nqH0T4w8/Untitled.png" alt="TryHackMe Logo" width="50">
      <img src="https://i.ibb.co/VpMLpFWc/j8m8atakekq1frdgg695.webp" alt="OffSec Logo" width="50">
      <img src="https://i.ibb.co/0y64r7m1/root-me-logo-png-seeklogo-505083.png" alt="RootMe Logo" width="50">
      Machines
    </h1>
  </div>

  <!-- Statistiques -->
  <div class="stats">
    <span><i class="fas fa-server"></i> Total Machines: {{ site.data.machines | size }}</span>
    <span><i class="fas fa-check-circle"></i> Terminées: {{ site.data.machines | where: "progression", "Done ✔️" | size }}</span>
    <span><i class="fab fa-linux"></i> Linux: {{ site.data.machines | where: "os", "Linux" | size }}</span>
    <span><i class="fab fa-windows"></i> Windows: {{ site.data.machines | where: "os", "Windows" | size }}</span>
    <span><i class="fab fa-windows"></i> Windows AD: {{ site.data.machines | where: "os", "Windows AD" | size }}</span>
  </div>

  <!-- Filtres -->
  <div class="filters">
    <div class="filter-group">
      <label for="platformFilter"><i class="fas fa-globe"></i> Plateforme:</label>
      <select id="platformFilter">
        <option value="all">Toutes</option>
        <option value="hackthebox">HackTheBox</option>
        <option value="tryhackme">TryHackMe</option>
        <option value="offsec">OffSec</option>
        <option value="rootme">RootMe</option>
      </select>
    </div>
    <div class="filter-group">
      <label for="osFilter"><i class="fas fa-laptop-code"></i> OS:</label>
      <select id="osFilter">
        <option value="all">Tous</option>
        <option value="linux">Linux</option>
        <option value="windows">Windows</option>
        <option value="windows ad">Windows AD</option>
      </select>
    </div>
    <div class="filter-group">
      <label for="difficultyFilter"><i class="fas fa-tachometer-alt"></i> Difficulté:</label>
      <select id="difficultyFilter">
        <option value="all">Toutes</option>
        <option value="easy">Easy</option>
        <option value="medium">Medium</option>
        <option value="hard">Hard</option>
        <option value="insane">Insane</option>
      </select>
    </div>
  </div>

  <!-- Barre de recherche -->
  <div class="search-bar">
    <input type="text" id="searchInput" placeholder="Rechercher machines, tâches ou compétences..." />
    <button><i class="fas fa-search"></i></button>
    <p>Machines trouvées: <span id="machineCount">{{ site.data.machines | size }}</span></p>
  </div>

  <!-- Tableau des machines -->
  <div class="table-container">
    <table class="machines-table">
      <thead>
        <tr>
          <th></th>
          <th>Nom</th>
          <th>Plateforme</th>
          <th>OS</th>
          <th>Difficulté</th>
          <th>Write-up</th>
          <th>ToDo</th>
        </tr>
      </thead>
      <tbody>
        {% for machine in site.data.machines %}
        <tr>
          <td>
            {% if machine.skills.size > 0 or machine.tasks.size > 0 %}
              <button class="toggle-details" data-machine="{{ machine.name | slugify }}"><i class="fas fa-chevron-down"></i></button>
            {% endif %}
          </td>
          <td data-label="Nom">{{ machine.name }}</td>
          <td data-label="Plateforme" data-value="{{ machine.platform | downcase }}">{{ machine.platform }}</td>
          <td data-label="OS" data-value="{{ machine.os | downcase }}">
            {% if machine.os == "Linux" %}
              <i class="fab fa-linux"></i> {{ machine.os }}
            {% elsif machine.os == "Windows" or machine.os == "Windows AD" %}
              <i class="fab fa-windows"></i> {{ machine.os }}
            {% else %}
              {{ machine.os }}
            {% endif %}
          </td>
          <td data-label="Difficulté" data-value="{{ machine.difficulty | downcase }}">
            <span class="difficulty {{ machine.difficulty | downcase }}">{{ machine.difficulty }}</span>
          </td>
          <td data-label="Write-up">
            {% if machine.writeup %}
              <a href="{{ machine.writeup }}" class="writeup-link">Lire Write-up</a>
            {% else %}
              -
            {% endif %}
          </td>
          <td data-label="ToDo">
            {% if machine.tasks.size > 0 %}
              <span class="task-count"><span class="completed-count" data-machine="{{ machine.name | slugify }}">0</span>/{{ machine.tasks.size }}</span>
            {% else %}
              -
            {% endif %}
          </td>
        </tr>
        {% if machine.skills.size > 0 or machine.tasks.size > 0 %}
        <tr class="details" style="display: none;" data-machine="{{ machine.name | slugify }}">
          <td colspan="7">
            <div class="details-container">
              {% if machine.skills.size > 0 %}
              <div class="tab">
                <input type="radio" id="tab-skills-{{ machine.name | slugify }}" name="tab-{{ machine.name | slugify }}" checked>
                <label for="tab-skills-{{ machine.name | slugify }}">Compétences</label>
                <div class="tab-content">
                  <h3><i class="fas fa-tools"></i> Compétences</h3>
                  <ul>
                    {% for skill in machine.skills %}
                    <li>{{ skill }}</li>
                    {% endfor %}
                  </ul>
                </div>
              </div>
              {% endif %}
              {% if machine.tasks.size > 0 %}
              <div class="tab">
                <input type="radio" id="tab-tasks-{{ machine.name | slugify }}" name="tab-{{ machine.name | slugify }}">
                <label for="tab-tasks-{{ machine.name | slugify }}">Tâches</label>
                <div class="tab-content">
                  <h3><i class="fas fa-tasks"></i> Tâches</h3>
                  <ul>
                    {% for task in machine.tasks %}
                    <li class="task">
                      <input type="checkbox" id="task-{{ machine.name | slugify }}-{{ forloop.index0 }}" data-machine="{{ machine.name | slugify }}"
                        {% if task.completed %}checked{% endif %}>
                      <label for="task-{{ machine.name | slugify }}-{{ forloop.index0 }}">
                        {{ task.description }}
                        {% if task.link %}
                          <a href="{{ task.link }}" class="task-link">Voir</a>
                        {% endif %}
                      </label>
                    </li>
                    {% endfor %}
                  </ul>
                </div>
              </div>
              {% endif %}
            </div>
          </td>
        </tr>
        {% endif %}
        {% endfor %}
      </tbody>
    </table>
  </div>
</div>

<style>
  .main-content {
    max-width: 960px;
    margin: 0 auto;
    padding: 0 20px;
  }
  .machines-header {
    text-align: center;
    margin-bottom: 30px;
  }
  .machines-header h1 {
    color: #ff4444;
    font-size: 2.5em;
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    margin: 0;
  }
  .stats {
    display: flex;
    justify-content: center;
    gap: 15px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }
  .stats span {
    background: #222;
    padding: 10px 15px;
    border-radius: 5px;
    color: #fff;
    font-size: 0.9em;
    display: flex;
    align-items: center;
    gap: 5px;
  }
  .filters {
    display: flex;
    justify-content: center;
    gap: 20px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }
  .filter-group {
    display: flex;
    align-items: center;
    gap: 5px;
  }
  .filters label {
    color: #fff;
    font-size: 0.9em;
  }
  .filters select {
    padding: 8px;
    background: #222;
    color: #fff;
    border: 1px solid #333;
    border-radius: 5px;
    font-size: 0.9em;
    transition: border-color 0.3s;
  }
  .filters select:hover {
    border-color: #ff4444;
  }
  .search-bar {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 10px;
    margin-bottom: 30px;
  }
  .search-bar input {
    padding: 12px;
    width: 100%;
    max-width: 450px;
    font-size: 1em;
    background: #222;
    color: #fff;
    border: 1px solid #333;
    border-radius: 5px;
    transition: border-color 0.3s;
  }
  .search-bar input:focus {
    border-color: #ff4444;
    outline: none;
  }
  .search-bar button {
    padding: 12px;
    background: #ff4444;
    color: #fff;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    font-size: 1em;
    transition: background 0.3s;
  }
  .search-bar button:hover {
    background: #cc3333;
  }
  .search-bar p {
    color: #fff;
    margin: 0;
    font-size: 0.9em;
  }
  .table-container {
    overflow-x: auto;
  }
  .machines-table {
    width: 100%;
    border-collapse: separate;
    border-spacing: 0;
    background: #1a1a1e;
    color: #fff;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
  }
  .machines-table th,
  .machines-table td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #333;
    font-size: 0.95em;
    vertical-align: middle;
  }
  .machines-table th {
    background: #222;
    font-weight: bold;
  }
  .machines-table tr:hover {
    background: #252525;
    transition: background 0.3s;
  }
  .toggle-details {
    background: none;
    border: none;
    color: #ff4444;
    font-size: 1.2em;
    cursor: pointer;
    transition: transform 0.3s;
  }
  .toggle-details.active i {
    transform: rotate(180deg);
  }
  .details-container {
    padding: 15px;
    background: #222;
    border-radius: 5px;
  }
  .tab {
    margin-bottom: 10px;
  }
  .tab input[type="radio"] {
    display: none;
  }
  .tab label {
    display: inline-block;
    padding: 10px 20px;
    background: #333;
    color: #fff;
    cursor: pointer;
    border-radius: 5px 5px 0 0;
    font-size: 0.9em;
    transition: background 0.3s;
  }
  .tab input[type="radio"]:checked + label {
    background: #ff4444;
  }
  .tab-content {
    display: none;
    padding: 15px;
    background: #1a1a1e;
    border: 1px solid #333;
    border-radius: 0 5px 5px 5px;
  }
  .tab input[type="radio"]:checked + label + .tab-content {
    display: block;
  }
  .tab-content h3 {
    color: #ff4444;
    margin-bottom: 10px;
    font-size: 1.2em;
    display: flex;
    align-items: center;
    gap: 5px;
  }
  .tab-content ul {
    margin: 0;
    padding-left: 20px;
    list-style: none;
  }
  .tab-content li {
    position: relative;
    margin-bottom: 8px;
    color: #ddd;
  }
  .tab-content li:not(.task):before {
    content: "•";
    color: #ff4444;
    position: absolute;
    left: -15px;
  }
  .task {
    display: flex;
    align-items: center;
  }
  .task input[type="checkbox"] {
    display: none;
  }
  .task label {
    display: flex;
    align-items: center;
    cursor: pointer;
    flex: 1;
  }
  .task input[type="checkbox"] + label:before {
    content: "\f0c8";
    font-family: "Font Awesome 6 Free";
    font-weight: 900;
    color: #f28c38;
    margin-right: 12px;
    font-size: 1.4em;
    transition: color 0.3s;
  }
  .task input[type="checkbox"]:checked + label:before {
    content: "\f14a";
    color: #28a745;
  }
  .task-link {
    color: #ff4444;
    text-decoration: none;
    margin-left: 8px;
    font-size: 0.9em;
    transition: color 0.3s;
  }
  .task-link:hover {
    color: #cc3333;
    text-decoration: underline;
  }
  .task-count {
    background: #333;
    padding: 5px 10px;
    border-radius: 5px;
    font-size: 0.9em;
    color: #fff;
  }
  .difficulty.easy { color: #28a745; }
  .difficulty.medium { color: #f28c38; }
  .difficulty.hard { color: #dc3545; }
  .difficulty.insane { color: #6f42c1; }
  .writeup-link {
    color: #ff4444;
    text-decoration: none;
    font-size: 0.9em;
    transition: color 0.3s;
  }
  .writeup-link:hover {
    color: #cc3333;
    text-decoration: underline;
  }
  @media (max-width: 768px) {
    .main-content {
      padding: 0 10px;
    }
    .machines-table {
      display: block;
      box-shadow: none;
    }
    .machines-table thead {
      display: none;
    }
    .machines-table tbody, .machines-table tr {
      display: block;
      margin-bottom: 20px;
      background: #222;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.3);
    }
    .machines-table td {
      display: flex;
      justify-content: space-between;
      padding: 10px;
      border-bottom: 1px solid #333;
    }
    .machines-table td:before {
      content: attr(data-label);
      font-weight: bold;
      color: #ff4444;
      flex: 0 0 100px;
    }
    .machines-table td:first-child {
      justify-content: center;
    }
    .machines-table .details {
      display: none !important;
    }
    .toggle-details.active + td + td + td + td + td + td + tr.details {
      display: table-row !important;
    }
    .search-bar input {
      width: 100%;
    }
    .filters {
      flex-direction: column;
      align-items: stretch;
    }
    .filter-group {
      width: 100%;
      margin-bottom: 10px;
    }
    .filters select {
      width: 100%;
    }
    .stats {
      flex-direction: column;
      gap: 10px;
    }
  }
</style>

<script>
  // Afficher/masquer les détails
  document.querySelectorAll(".toggle-details").forEach((toggle) => {
    toggle.addEventListener("click", () => {
      const machineId = toggle.getAttribute("data-machine");
      const detailsRow = document.querySelector(`tr.details[data-machine="${machineId}"]`);
      if (detailsRow.style.display === "none" || !detailsRow.style.display) {
        detailsRow.style.display = "table-row";
        toggle.classList.add("active");
      } else {
        detailsRow.style.display = "none";
        toggle.classList.remove("active");
      }
    });
  });

  // Initialiser les checkboxes depuis localStorage
  function loadTasks() {
    document.querySelectorAll(".task input[type=\"checkbox\"]").forEach((checkbox) => {
      const taskId = checkbox.id;
      const isChecked = localStorage.getItem(taskId) === "true";
      checkbox.checked = isChecked || checkbox.hasAttribute("checked");
    });
    updateProgress();
  }

  // Mettre à jour les compteurs de tâches
  function updateProgress() {
    document.querySelectorAll(".task-count .completed-count").forEach((counter) => {
      const machine = counter.getAttribute("data-machine");
      const tasks = document.querySelectorAll(`input[data-machine="${machine}"]:checked`);
      counter.textContent = tasks.length;
    });
  }

  // Écouteurs pour les checkboxes
  document.querySelectorAll(".task input[type=\"checkbox\"]").forEach((checkbox) => {
    checkbox.addEventListener("change", () => {
      localStorage.setItem(checkbox.id, checkbox.checked);
      updateProgress();
    });
  });

  // Appliquer les filtres et la recherche
  function applyFiltersAndSearch() {
    const platformFilter = document.getElementById("platformFilter").value;
    const osFilter = document.getElementById("osFilter").value;
    const difficultyFilter = document.getElementById("difficultyFilter").value;
    const searchTerm = document.getElementById("searchInput").value.toLowerCase();
    const rows = document.querySelectorAll(".machines-table tbody tr:not(.details)");
    let visibleCount = 0;

    rows.forEach((row) => {
      const name = row.cells[1].textContent.toLowerCase();
      const platform = row.cells[2].getAttribute("data-value") || "";
      const os = row.cells[3].getAttribute("data-value") || "";
      const difficulty = row.cells[4].getAttribute("data-value") || "";
      const detailsRow = document.querySelector(`tr.details[data-machine="${row.cells[1].textContent.toLowerCase().replace(/\s+/g, '-')}"]`);
      const detailsText = detailsRow ? detailsRow.textContent.toLowerCase() : "";

      const matchesSearch =
        name.includes(searchTerm) ||
        platform.includes(searchTerm) ||
        os.includes(searchTerm) ||
        difficulty.includes(searchTerm) ||
        detailsText.includes(searchTerm);

      const matchesPlatform = platformFilter === "all" || platform === platformFilter;
      const matchesOs = osFilter === "all" || os === osFilter;
      const matchesDifficulty = difficultyFilter === "all" || difficulty === difficultyFilter;

      if (matchesSearch && matchesPlatform && matchesOs && matchesDifficulty) {
        row.style.display = "";
        visibleCount++;
      } else {
        row.style.display = "none";
      }
    });

    document.getElementById("machineCount").textContent = visibleCount;
  }

  // Écouteurs pour les filtres et la recherche
  document.getElementById("platformFilter").addEventListener("change", applyFiltersAndSearch);
  document.getElementById("osFilter").addEventListener("change", applyFiltersAndSearch);
  document.getElementById("difficultyFilter").addEventListener("change", applyFiltersAndSearch);
  document.getElementById("searchInput").addEventListener("input", applyFiltersAndSearch);

  // Charger les tâches et appliquer les filtres au démarrage
  window.addEventListener("load", () => {
    loadTasks();
    applyFiltersAndSearch();
  });
</script>