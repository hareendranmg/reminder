#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

// Single-instance mutex name (must match app identity).
constexpr const wchar_t kSingleInstanceMutex[] = L"Local\\com.hareendranmg.reminder";

// Main window title set by the app (AppConstants.appName) or initial title.
constexpr const wchar_t kAppWindowTitle[] = L"Reminder";
constexpr const wchar_t kAppWindowTitleLower[] = L"reminder";

HWND g_existing_main_window = nullptr;

BOOL CALLBACK FindMainWindowByTitle(HWND hwnd, LPARAM lparam) {
  wchar_t title[256] = {};
  if (::GetWindowTextW(hwnd, title, 256) == 0) {
    return TRUE;  // continue enumeration
  }
  // Match "Reminder" or "reminder" (initial title from Create()).
  if (::_wcsicmp(title, kAppWindowTitle) == 0 ||
      ::_wcsicmp(title, kAppWindowTitleLower) == 0) {
    g_existing_main_window = hwnd;
    return FALSE;  // stop enumeration
  }
  return TRUE;
}

// If another instance is running, bring its window to front and return true.
bool TryActivateExistingInstance() {
  g_existing_main_window = nullptr;
  ::EnumWindows(FindMainWindowByTitle, 0);
  if (g_existing_main_window == nullptr) {
    return false;
  }
  if (::IsIconic(g_existing_main_window)) {
    ::ShowWindow(g_existing_main_window, SW_RESTORE);
  }
  ::SetForegroundWindow(g_existing_main_window);
  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Single-instance: if another instance is running, show its window and exit.
  HANDLE mutex = ::CreateMutexW(nullptr, FALSE, kSingleInstanceMutex);
  const bool already_running = (mutex != nullptr &&
                              ::GetLastError() == ERROR_ALREADY_EXISTS);
  if (mutex != nullptr) {
    ::CloseHandle(mutex);
  }
  if (already_running) {
    if (TryActivateExistingInstance()) {
      return 0;  // Successfully activated existing window.
    }
    // Existing process might be starting up; exit anyway to avoid duplicates.
    return 0;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"reminder", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
