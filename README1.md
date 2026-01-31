# 🚀 Launcher Flutter – Documentazione del Progetto

Questo progetto implementa un **launcher multipiattaforma** sviluppato in Flutter, con configurazione iniziale, login, caricamento dinamico della configurazione e gestione dello stato tramite **Riverpod**.

Di seguito trovi una descrizione chiara e completa di ogni file Dart principale, così da capire esattamente come funziona l’intero sistema.

---

## 📂 lib/main.dart
### Funzione
- Punto di ingresso dell’app.
- Inizializza Riverpod tramite `ProviderScope`.
- Decide quale pagina mostrare all’avvio:
  - **SetupPage** se la configurazione non è presente.
  - **LauncherPage** se la configurazione è valida.
- Gestisce lo stato asincrono tramite `configProvider`.

### Perché è importante
È il cuore del bootstrap dell’app: determina il flusso iniziale e garantisce che l’utente veda la schermata corretta.

---

## 📂 lib/controllers/config_controller.dart
### Funzione
- Gestisce la configurazione dell’app (URL, user, password).
- Carica la configurazione salvata all’avvio (`build()`).
- Esegue il login tramite `ApiService`.
- Salva la configurazione tramite `StorageService`.
- Espone uno stato asincrono: `AsyncValue<ConfigModel?>`.

### Perché è importante
È il controller che decide se l’app è configurata, se il login è valido e se si può accedere al launcher.

---

## 📂 lib/controllers/launcher_controller.dart
### Funzione
- Gestisce la logica della schermata principale del launcher.
- Legge la configurazione tramite `configProvider`.
- Esegue chiamate API, caricamenti o operazioni necessarie al launcher.
- Contiene funzioni operative che dipendono dalla configurazione salvata.

### Perché è importante
È il cervello della schermata principale: tutto ciò che il launcher deve fare passa da qui.

---

## 📂 lib/models/config_model.dart
### Funzione
- Rappresenta la configurazione dell’app:
  - `uri`
  - `user`
  - `password`
- Fornisce:
  - `toJson()` per salvare
  - `fromJson()` per caricare

### Perché è importante
È il modello dati che rappresenta la configurazione persistente dell’app.

---

## 📂 lib/services/storage_service.dart
### Funzione
- Salva e carica la configurazione tramite SharedPreferences.
- Serializza e deserializza `ConfigModel`.

### Perché è importante
Permette all’app di ricordare la configurazione tra un avvio e l’altro.

---

## 📂 lib/services/api_service.dart
### Funzione
- Gestisce le chiamate HTTP verso il backend.
- Implementa il login.
- Restituisce un token o `null` in caso di errore.

### Perché è importante
È il punto di comunicazione tra app e server.

---

## 📂 lib/pages/setup_page.dart
### Funzione
- Pagina iniziale per inserire:
  - URL
  - User
  - Password
- Chiama `saveAndLogin()` del `configProvider`.
- Se la configurazione è valida → apre `LauncherPage`.
- Mostra errori in caso di credenziali errate.

### Perché è importante
È la pagina che permette all’utente di configurare l’app la prima volta.

---

## 📂 lib/pages/launcher_page.dart
### Funzione
- Schermata principale dell’app.
- Mostra le funzionalità del launcher.
- Usa `LauncherController` per logica e dati.

### Perché è importante
È la UI principale dell’app dopo la configurazione.

---

## 📂 lib/utils/image_utils.dart
### Funzione
- Gestisce il caricamento e la manipolazione delle immagini.
- Esegue:
  - crop quadrato
  - resize
  - conversione in PNG o WebP (a seconda della versione)
- Restituisce un data URL o bytes elaborati.

### Perché è importante
Serve per generare icone o immagini ottimizzate per il launcher.

---

## 📂 lib/widgets/ (se presente)
### Funzione
- Contiene widget riutilizzabili.
- Componenti UI modulari.

---

## 📂 lib/theme/ (se presente)
### Funzione
- Gestisce colori, stili, temi Material.

---

## 📂 lib/routes/ (se presente)
### Funzione
- Definisce le rotte dell’app.
- Gestisce la navigazione centralizzata.

---

## 🧩 Flusso generale dell’app

Il comportamento dell’app segue una pipeline chiara basata sul caricamento asincrono della configurazione tramite Riverpod:

1. **Avvio dell’app**
2. `configProvider.build()` viene eseguito
3. Viene caricata la configurazione salvata tramite `StorageService`
4. **Se la configurazione NON esiste**
   - viene mostrata la `SetupPage`
5. **Se la configurazione ESISTE**
   - viene mostrata la `LauncherPage`
6. L’utente compila la `SetupPage` e preme **Salva**
7. `saveAndLogin()`:
   - tenta il login tramite `ApiService`
   - se valido → salva la configurazione
   - aggiorna lo stato con `AsyncData(config)`
8. La UI rileva che `configProvider` ha un valore valido
9. Navigazione automatica verso `LauncherPage`
10. **Al riavvio dell’app**
    - `configProvider` ricarica la configurazione
    - l’app salta la SetupPage e apre direttamente la LauncherPage
