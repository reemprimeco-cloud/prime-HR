/* Prime HR service worker: fast repeat loads + offline app shell.
   - Pages: network-first (always fresh when online), cached copy when offline.
   - Static assets & pinned CDN libraries/fonts: cache-first.
   - Supabase API and anything else: never cached (always live data). */
const CACHE = 'prime-hr-v1';
const SHELL = [
  './',
  './index.html',
  './manifest.webmanifest',
  './assets/logo.webp',
  './assets/favicon.png',
  './assets/apple-touch-icon.png',
  './assets/icon-192.webp',
  './assets/icon-512.webp'
];
const CACHEABLE_HOSTS = ['cdn.jsdelivr.net', 'cdnjs.cloudflare.com', 'fonts.googleapis.com', 'fonts.gstatic.com'];

self.addEventListener('install', function(event){
  event.waitUntil(caches.open(CACHE).then(function(c){ return c.addAll(SHELL); }).then(function(){ return self.skipWaiting(); }));
});

self.addEventListener('activate', function(event){
  event.waitUntil(
    caches.keys().then(function(keys){
      return Promise.all(keys.filter(function(k){ return k !== CACHE; }).map(function(k){ return caches.delete(k); }));
    }).then(function(){ return self.clients.claim(); })
  );
});

function cacheFirst(request){
  return caches.match(request).then(function(hit){
    if(hit) return hit;
    return fetch(request).then(function(res){
      if(res && (res.ok || res.type === 'opaque')){
        const copy = res.clone();
        caches.open(CACHE).then(function(c){ c.put(request, copy); });
      }
      return res;
    });
  });
}

self.addEventListener('fetch', function(event){
  const req = event.request;
  if(req.method !== 'GET') return;
  const url = new URL(req.url);

  if(req.mode === 'navigate'){
    event.respondWith(
      fetch(req).then(function(res){
        const copy = res.clone();
        caches.open(CACHE).then(function(c){ c.put('./index.html', copy); });
        return res;
      }).catch(function(){ return caches.match('./index.html'); })
    );
    return;
  }

  if(url.origin === self.location.origin){
    event.respondWith(cacheFirst(req));
    return;
  }

  if(CACHEABLE_HOSTS.indexOf(url.hostname) !== -1){
    event.respondWith(cacheFirst(req));
  }
  // Supabase and other origins: default network handling (no caching of HR data)
});
