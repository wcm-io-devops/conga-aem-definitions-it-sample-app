Dispatcher Integration Tests
============================

### Run integration tests for AEMaaCS

```bash
mvn clean verify -Dintegrationtests.skip=false
```

### Run integration tests for AEM 6.5

```bash
mvn clean verify -Dintegrationtests.skip=false -Paem65
```

### Run integration tests for AEM 6.6

```bash
mvn clean verify -Dintegrationtests.skip=false -Paem66
```
