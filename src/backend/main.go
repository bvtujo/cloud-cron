package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
	"sync"
)

const (
	headerKey = "Key"
)

type GetResponse struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

type SetRequest struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}

type KV struct {
	sync.Mutex
	store map[string]string
}

func (k *KV) Get(key string) (string, error) {

	if val, ok := k.store[key]; ok {
		return val, nil
	}
	return "", fmt.Errorf("key %s not found", key)
}

func (k *KV) Set(key, value string) {
	log.Printf("set: %s = %s", key, value)
	k.Lock()
	defer k.Unlock()

	k.store[key] = value
	return
}

func setHandler(k *KV) func(w http.ResponseWriter, r *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		var body SetRequest
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		k.Set(body.Key, body.Value)
		return
	}
}

func getHandler(k *KV) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		key := r.Header.Get(headerKey)
		log.Printf("get: %s", key)
		if key == "" {
			http.Error(w, "bad request", http.StatusBadRequest)
			return
		}
		val, err := k.Get(key)
		if err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		resp := GetResponse{
			Key:   key,
			Value: val,
		}
		json.NewEncoder(w).Encode(resp)
		return
	}

}

func NewKVStore() (kv *KV) {
	kv = &KV{
		store: make(map[string]string),
	}

	return
}

func main() {

	kv := NewKVStore()
	log.Printf("initialized kv store")

	r := mux.NewRouter()
	r.HandleFunc("/", getHandler(kv)).Methods(http.MethodGet)
	r.HandleFunc("/", setHandler(kv)).Methods(http.MethodPost)

	srv := http.Server{
		Handler: r,
		Addr:    ":8080",
	}
	log.Fatal(srv.ListenAndServe())
}
