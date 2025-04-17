<script setup lang="ts">
import { ref } from 'vue'
import axios from 'axios'

const axiosInstance = axios.create({
  baseURL: 'http://localhost:8080/',
});

const data = ref<string>("");
const getData = async () => {
  let result = await axiosInstance.get("/hello");
  data.value = result.data;
};
</script>

<template>
  <button @click="getData">click</button>
  {{ data }}
</template>