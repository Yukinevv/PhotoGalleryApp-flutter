# PhotoGalleryApp

PhotoGalleryApp to aplikacja mobilna stworzona przy użyciu Fluttera, która umożliwia użytkownikom przeglądanie, dodawanie, edytowanie i usuwanie zdjęć. Aplikacja pozwala również na logowanie i rejestrację użytkowników oraz zarządzanie kategoriami zdjęć.

## Funkcjonalności

- **Logowanie i rejestracja użytkowników**: Użytkownicy mogą się rejestrować, logować i wylogowywać.
- **Przeglądanie zdjęć**: Użytkownicy mogą przeglądać zdjęcia w różnych kategoriach.
- **Dodawanie zdjęć**: Użytkownicy mogą dodawać zdjęcia z galerii lub zrobić nowe zdjęcie za pomocą aparatu.
- **Edytowanie zdjęć**: Użytkownicy mogą zmieniać nazwę zdjęć oraz przycinać zdjęcia przed ich dodaniem.
- **Usuwanie zdjęć**: Użytkownicy mogą usuwać zdjęcia.
- **Filtrowanie i sortowanie**: Możliwość filtrowania zdjęć po nazwie oraz sortowania w kolejności alfabetycznej rosnącej lub malejącej.
- **Zarządzanie kategoriami**: Użytkownicy mogą przeglądać zdjęcia w różnych kategoriach.
- **Ustawienia użytkownika**: Zmiana hasła i wylogowanie.
- **Przekierowanie do linku**: Możliwość otwarcia linków w przeglądarce z poziomu aplikacji.

## Instalacja

Aby uruchomić ten projekt lokalnie, wykonaj poniższe kroki:

1. **Sklonuj repozytorium:**

    ```bash
    git clone https://github.com/Yukinevv/PhotoGalleryApp-flutter.git
    cd PhotoGalleryApp-flutter
    ```

2. **Zainstaluj zależności:**

    ```bash
    flutter pub get
    ```

3. **Uruchom aplikację:**

    ```bash
    flutter run
    ```

## Użycie

### Logowanie i rejestracja

- **Logowanie**: Wprowadź swoje dane logowania i kliknij przycisk "Zaloguj".
- **Rejestracja**: Kliknij przycisk "Nie masz konta? Zarejestruj się", wypełnij formularz rejestracyjny i kliknij "Zarejestruj się".

### Przeglądanie i zarządzanie zdjęciami

- **Przeglądanie zdjęć**: Po zalogowaniu wybierz kategorię, aby wyświetlić zdjęcia w tej kategorii.
- **Dodawanie zdjęć**: Kliknij przycisk "Dodaj obraz", wybierz plik lub zrób zdjęcie, przytnij je (opcjonalnie) i dodaj do wybranej kategorii.
- **Edytowanie zdjęć**: Kliknij na zdjęcie, które chcesz edytować, zmień jego nazwę lub przytnij je, a następnie zapisz zmiany.
- **Usuwanie zdjęć**: Kliknij na zdjęcie, które chcesz usunąć, i potwierdź usunięcie.

### Ustawienia

- **Zmiana hasła**: Przejdź do ustawień, wybierz opcję "Zmień hasło", wprowadź nowe hasło i zapisz zmiany.
- **Wylogowanie**: Przejdź do ustawień i wybierz opcję "Wyloguj".

### Linki

- **Link do API**: W ustawieniach kliknij "Link do API", aby otworzyć stronę API w przeglądarce.
- **Inny link**: W ustawieniach kliknij "Inny link", aby otworzyć stronę wikipedii w przeglądarce.

## Technologie

- **Flutter**: Framework do tworzenia aplikacji mobilnych.
- **Dart**: Język programowania używany w Flutterze.
- **HTTP**: Używane do komunikacji z API.
- **SharedPreferences**: Używane do zapisywania danych logowania.
- **ImageCropper**: Biblioteka do przycinania zdjęć.
- **File Picker**: Biblioteka do wybierania plików z urządzenia.
- **URL Launcher**: Biblioteka do otwierania linków w przeglądarce.

## Autor

Adrian Rodzic
