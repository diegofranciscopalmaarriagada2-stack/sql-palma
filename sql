<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Subir archivo</title>
</head>
<body>

  <input type="file" id="fileInput">
  <button onclick="uploadFile()">Subir</button>

  <br><br>
  <div id="status"></div>
  <br>
  <div id="downloadSection"></div>

  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js";
    import { getStorage, ref, uploadBytesResumable, getDownloadURL, listAll } from "https://www.gstatic.com/firebasejs/10.12.0/firebase-storage.js";

    const firebaseConfig = {
      apiKey: "AIzaSyAnb0MYXcv17QhrC9Of-yddQ0-8ulP8yFI",
      authDomain: "ferreteria-colon.firebaseapp.com",
      projectId: "ferreteria-colon",
      storageBucket: "ferreteria-colon.firebasestorage.app",
      messagingSenderId: "310069936985",
      appId: "1:310069936985:web:72fcc8776c80f886fc0248",
      measurementId: "G-L3E4CY9VNJ"
    };

    const app = initializeApp(firebaseConfig);
    const storage = getStorage(app);

    // Load existing files on page load
    async function loadFiles() {
      const listRef = ref(storage, 'uploads/');
      try {
        const res = await listAll(listRef);
        const section = document.getElementById('downloadSection');
        section.innerHTML = '<strong>Archivos subidos:</strong><br>';
        for (const itemRef of res.items) {
          const url = await getDownloadURL(itemRef);
          const a = document.createElement('a');
          a.href = url;
          a.download = itemRef.name;
          a.textContent = 'Descargar: ' + itemRef.name;
          section.appendChild(a);
          section.appendChild(document.createElement('br'));
        }
        if (res.items.length === 0) {
          section.innerHTML += 'No hay archivos aún.';
        }
      } catch (e) {
        document.getElementById('downloadSection').textContent = 'No se pudieron listar los archivos.';
      }
    }

    window.uploadFile = function () {
      const fileInput = document.getElementById('fileInput');
      const file = fileInput.files[0];
      const status = document.getElementById('status');

      if (!file) {
        status.textContent = 'Selecciona un archivo primero.';
        return;
      }

      const storageRef = ref(storage, 'uploads/' + file.name);
      const uploadTask = uploadBytesResumable(storageRef, file);

      uploadTask.on('state_changed',
        (snapshot) => {
          const progress = Math.round((snapshot.bytesTransferred / snapshot.totalBytes) * 100);
          status.textContent = 'Subiendo... ' + progress + '%';
        },
        (error) => {
          status.textContent = 'Error: ' + error.message;
        },
        async () => {
          const url = await getDownloadURL(uploadTask.snapshot.ref);
          status.textContent = 'Subido correctamente.';
          loadFiles();
        }
      );
    };

    loadFiles();
  </script>

</body>
</html>
