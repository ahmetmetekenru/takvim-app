// Kabuğun service worker'ı: kabuk dosyalarını cihazda saklar, böylece uygulama internetsiz de açılır.
// Takvim verisi burada saklanmaz; onu index.html kendisi (localStorage'da) tutar.
// Kabuk dosyalarını değiştirince CACHE_NAME'i artır (v3, v4...) ki eski kopyalar silinsin.
const CACHE_NAME = "takvim-app-v4";
const SHELL_FILES = ["./", "index.html", "manifest.webmanifest", "icon-192.png", "icon-512.png"];

// Kurulurken kabuk dosyalarını hemen sakla (ilk açılıştan sonra internetsiz de açılsın)
self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(SHELL_FILES)));
  self.skipWaiting();
});

// Eski sürümlerin sakladığı dosyaları sil
self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((names) => Promise.all(names.filter((name) => name !== CACHE_NAME).map((name) => caches.delete(name))))
  );
  self.clients.claim();
});

// Önce internetten dener (güncel kalsın), olmazsa saklanan kopyayı verir
self.addEventListener("fetch", (event) => {
  const sameOrigin = new URL(event.request.url).origin === self.location.origin;
  if (event.request.method !== "GET" || !sameOrigin) return;

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request, { ignoreSearch: true }))
  );
});
