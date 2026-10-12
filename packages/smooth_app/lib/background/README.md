## Debugging Steps for Background Tasks in Smooth App

### 1. **Check Server Responsiveness**
- **Is the Open Food Facts server slow or down?**
  - Test server reachability: Try accessing the API or website in a browser.
  - Look for server status pages or community reports of outages.
  - If the server is slow, background tasks may timeout or fail with “Server timeout” or similar errors (see: `background_task_error_server_time_out`).

### 2. **Product Movement Between Projects**
- **Has the product/barcode moved to a different Open Products Facts instance (e.g., from Open Food Facts to Open Beauty Facts)?**
  - Check which project the barcode belongs to on the web.
  - If moved, background tasks may fail or be rejected by the server.

### 3. **Network Conditions**
- **WiFi vs Metered Connection (Mobile Data)**
  - On metered connections, some operating systems or user settings may restrict background network activity.
  - On Android/iOS, check if the app has permission to use data in the background.
- **Data Saver Mode**
  - If enabled, this may pause or throttle background tasks.
  - Advise users to disable Data Saver for the app if they expect real-time syncing.

### 4. **Connectivity**
- **No Internet or Flaky Connections**
  - Tasks will be retried later if the connection is lost (see code: `taskStatusNoInternet`).
  - Test with a stable connection.
  - Check if other apps can access the internet.

### 5. **App Lifecycle**
- **App Needs to Be Open**
  - Background tasks in Smooth App typically require the app to be in the foreground or not aggressively killed by the OS.
  - On iOS, background execution is much more restricted than Android.
  - Advise users to keep the app open for a while after making changes.

### 6. **Operating System Restrictions**
- **iOS Background Execution**
  - iOS limits background execution unless using specific APIs (background fetch, silent push, etc.).
  - If the app is closed or in the background for too long, tasks may not run until the user brings the app to the foreground.
- **Android Doze/Battery Optimization**
  - Check if the app is exempt from battery optimizations.

### 7. **File Path Issues (iOS Bug)**
- **Current Bug: iOS Filepath**
  - There is a known issue affecting file paths on iOS (e.g., uploads may fail if the app cannot access the selected file).
  - A fix has been merged for this, and will be in the next release
  - Try with a different image or file to see if the problem persists.

### 8. **App Permissions**
- Ensure the app has permissions for:
  - Network access
  - Background data usage
  - Storage (for reading files/images to upload)

### 9. **Check Task Queue**
- **Pending Tasks**
  - Check if tasks are stuck, duplicated, or failing repeatedly.
  - You can view pending background tasks in the Smooth App (UI may display this info).
- **Task Errors**
  - Error logs may indicate why a task failed (e.g., “No internet”, “Server timeout”, etc.).

### 10. **Logs and Debugging**
- **Enable debug logging**
  - Look at the debug output for messages from `BackgroundTaskManager`.
  - Check for repeated errors or messages about duplicate stamps.
- **Review device logs**
  - Use Android Studio/Flutter DevTools to inspect logs.

### 11. **Storage and Local Database**
- **Database Corruption**
  - If the local database is corrupted, tasks may not be stored or executed properly.
  - Try clearing app data or reinstalling the app.

### 12. **App Version**
- **Update to the Latest Version**
  - Ensure you are using the latest release with all known bug fixes, especially regarding the iOS filepath bug.

---

## Summary Table

| Issue/Setting                  | Debugging Step/Check                                   |
|------------------------------- |------------------------------------------------------ |
| Server slow/unreachable        | Test API/website, check status reports                |
| Product moved between projects | Check barcode on OFF/OBF/other sites                  |
| WiFi vs metered/data saver     | Try on WiFi, disable data saver, check permissions    |
| Connectivity                   | Verify stable internet, try other apps                |
| App must be open               | Keep app foregrounded after making changes            |
| OS background restrictions     | Check iOS/Android background settings                 |
| iOS filepath bug               | Try the internal build once the PR is merged.         |
| Permissions                    | Verify network, storage, background data permissions  |
| Task queue/issues              | View in-app task queue UI, inspect for stuck tasks    |
| Logs and debugging             | Enable debug logs, inspect error/status messages      |
| Local database/storage         | Clear app data, reinstall if corruption suspected     |
| App version                    | Update to latest version                              |

---

### How the Background Tasks System Works

#### Architecture & Core Concepts
- **BackgroundTaskManager**: Central class managing background tasks. Handles single-threaded execution, blocking, restarting, and displaying tasks.
- **Task Queues**: Tasks are organized into different queues (`fast`, `slow`, `longHaul`), each with its own timing and processing characteristics.
  - Each queue has settings for:
    - Minimum duration between runs
    - Maximum time a task run is allowed before considering it failed
    - Database keys for storing start/stop times and the queue itself
- **Task Structure**:
  - Each background task is a subclass of `BackgroundTask`.
  - Tasks have a `processName`, a unique ID, a "stamp" for deduplication, user/language/country metadata, and are (de)serializable to JSON.
  - Tasks implement an `execute(LocalDatabase)` method to perform their work.
  - There are specialized types like `BackgroundTaskProgressing` for paged/incremental work, and concrete implementations for product uploads, downloads, "Hunger Games," etc.

#### Task Lifecycle
- **Adding Tasks**: Tasks are added to the appropriate queue and immediately trigger a run if possible.
- **Executing Tasks**: The manager fetches runnable tasks (skipping those scheduled for later, or currently not eligible), deduplicates tasks by "stamp," and runs them in order.
- **Task Execution**:
  - Tasks may perform recovery steps before running.
  - If a task fails (e.g., due to no internet), it's marked as such and retried later.
  - If a newer task with the same "stamp" appears, older duplicates are removed.
- **Finishing Tasks**: After execution, a task's `postExecute` is called, and it's removed from the queue.
- **Error Handling**:
  - Errors are recorded (e.g., "No internet, try later!").
  - If a task fails but is superseded by a newer one, it's safely discarded.
- **Task Statuses**: Tasks can have statuses like "started," "no internet," or custom error messages.
- **Manual Triggers**: The system can force an immediate run of all task queues.

#### Persistence
- **Local Storage**: Task info and statuses are stored in the local database for reliability and recovery after restarts.
- **Timestamps**: Start/stop times are tracked to ensure tasks don't overlap or get stuck indefinitely.

---

### Current Limitations & Known Issues

- **Single-threaded Execution**: Tasks are run in a single-threaded fashion per queue. If a task takes a long time, subsequent tasks are delayed.
- **Deduplication Logic**: Only the latest task for a given "stamp" (except some uploads) will be executed; earlier ones are discarded. This can sometimes lead to lost intermediate work if many similar tasks are queued quickly.
- **Error Handling**:
  - If there's no network, tasks are retried later, but persistent failures might require user intervention.
  - Some error messages (like "No internet") are generic.
- **Task Management**:
  - If a task fails, it remains until it succeeds or is overwritten.
  - There are TODOs in the code about cleaning up or improving task management, especially as the system and use cases evolve.
- **Debugging**: There are debug print statements and TODOs indicating areas for potential improvement or more robust logging.
- **User Feedback**: UI strings note that contributions are saved automatically but not always in real time, reflecting the asynchronous nature and possible delays in background processing.
- **Legacy Code/Upgrades**: Some classes have logic for backward compatibility (e.g., product type defaults for legacy tasks).
- **Security**: There's a TODO about not storing passwords in clear text in the task data.

---

### In Summary

The background tasks system is a robust, queue-based mechanism for processing uploads, downloads, and other operations asynchronously. It uses local persistence, deduplication, and error handling to ensure reliability, but is currently single-threaded, has some rough edges in error recovery and task deduplication, and has ongoing areas for cleanup and improvement.

If you need a more detailed breakdown of a specific part (e.g., how uploads are handled, or how to add new task types), let me know!
