// Source: https://github.com/google/sanitizers/issues/89#issuecomment-406316683

int dlclose(void *ptr) {
    return 0;
}
