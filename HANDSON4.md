# Hands-on 4. Run tests on parallel

In this section, edit the configuration to test in parallel.

1. Move `launchable subset` command to primary
1. Run test on parallel (worker1 ~ 4)

Before starting it, make a new branch `PR3`.

```
$ git switch -c PR3
$ git push origin PR3
```

## Move `launchable subset` command to primary

In this part, move `launchable subset` command from worker node to primary node and pass the subset id to workers from primary instead of the test session.

TODO(Konboi): explain split subset

```diff
   primary-node:
     runs-on: ubuntu-latest
     outputs:
-      test_session: ${{ steps.issue_test_session.outputs.test_session}}
+      subset_id: ${{ steps.issue_subset_id.outputs.subset_id}}
     steps:
       - uses: actions/checkout@v3
         with:

...

         id: issue_test_session
         run: |
           launchable record session --build ${{ github.run_id }} > test_session.txt
-          test_session=$(cat test_session.txt)
-          echo $test_session
-          echo "::set-output name=test_session::$test_session"
       - name: Compile
         run: mvn compile
+      - name: Launchable subset
+        id: issue_subset_id
+        run: |
+          mvn test-compile
+          launchable subset --session $( cat test_session.txt ) --target 75% --split maven --test-compile-created-file target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst > launchable-subset-id.txt
+          subset_id=$(cat launchable-subset-id.txt)
+          echo "::set-output name=subset_id::$subset_id"
   worker-node-1:
     runs-on: ubuntu-latest
     needs: [ primary-node ]

...

           python-version: '3.10'
       - name: Install Launchable command
         run: pip install --user --upgrade launchable~=1.0
-      - name: Restore test session
-        run: echo -n '${{needs.primary-node.outputs.test_session}}' > test_session.txt
+      - name: Restore subset_id
+        run: echo -n '${{needs.primary-node.outputs.subset_id}}' > launchable-subset-id.txt
       - name: Launchable subset
         run: |
           mvn test-compile
-          launchable subset --session $( cat test_session.txt ) --target 75% maven --test-compile-created-file target/maven-status/maven-compiler-plugin/testCompile/default-testCompile/createdFiles.lst > launchable-subset.txt
+          launchable split-subset --subset-id $( cat launchable-subset-id.txt ) --bin 1/4 maven  > launchable-subset.txt
           cat launchable-subset.txt
       - name: Test
         run: mvn test -Dsurefire.includesFile=launchable-subset.txt
       - name: Launchable record tests
         if: always()
-        run: launchable record tests --session $(cat test_session.txt) maven ./**/target/surefire-reports
+        run: launchable record tests --subset-id $( cat launchable-subset-id.txt ) maven ./**/target/surefire-reports
```

Add worker 2 to 4

```diff
       - name: Launchable record tests
         if: always()
         run: launchable record tests --subset-id $( cat launchable-subset-id.txt ) maven ./**/target/surefire-reports
+  worker-node-2:
+    runs-on: ubuntu-latest
+    needs: [ primary-node ]
+    steps:
+      - uses: actions/checkout@v3
+      - uses: actions/setup-java@v3
+        with:
+          java-version: 11
+          distribution: "adopt"
+      - uses: actions/setup-python@v3
+        with:
+          python-version: '3.10'
+      - name: Install Launchable command
+        run: pip install --user --upgrade launchable~=1.0
+      - name: Restore subset_id
+        run: echo -n '${{needs.primary-node.outputs.subset_id}}' > launchable-subset-id.txt
+      - name: Launchable subset
+        run: |
+          mvn test-compile
+          launchable split-subset --subset-id $( cat launchable-subset-id.txt ) --bin 2/4 maven  > launchable-subset.txt
+          cat launchable-subset.txt
+      - name: Test
+        run: mvn test -Dsurefire.includesFile=launchable-subset.txt
+      - name: Launchable record tests
+        if: always()
+        run: launchable record tests --subset-id $( cat launchable-subset-id.txt ) maven ./**/target/surefire-reports
+  worker-node-3:
+    runs-on: ubuntu-latest
+    needs: [ primary-node ]
+    steps:
+      - uses: actions/checkout@v3
+      - uses: actions/setup-java@v3
+        with:
+          java-version: 11
+          distribution: "adopt"
+      - uses: actions/setup-python@v3
+        with:
+          python-version: '3.10'
+      - name: Install Launchable command
+        run: pip install --user --upgrade launchable~=1.0
+      - name: Restore subset_id
+        run: echo -n '${{needs.primary-node.outputs.subset_id}}' > launchable-subset-id.txt
+      - name: Launchable subset
+        run: |
+          mvn test-compile
+          launchable split-subset --subset-id $( cat launchable-subset-id.txt ) --bin 3/4 maven  > launchable-subset.txt
+          cat launchable-subset.txt
+      - name: Test
+        run: mvn test -Dsurefire.includesFile=launchable-subset.txt
+      - name: Launchable record tests
+        if: always()
+        run: launchable record tests --subset-id $( cat launchable-subset-id.txt ) maven ./**/target/surefire-reports
+  worker-node-4:
+    runs-on: ubuntu-latest
+    needs: [ primary-node ]
+    steps:
+      - uses: actions/checkout@v3
+      - uses: actions/setup-java@v3
+        with:
+          java-version: 11
+          distribution: "adopt"
+      - uses: actions/setup-python@v3
+        with:
+          python-version: '3.10'
+      - name: Install Launchable command
+        run: pip install --user --upgrade launchable~=1.0
+      - name: Restore subset_id
+        run: echo -n '${{needs.primary-node.outputs.subset_id}}' > launchable-subset-id.txt
+      - name: Launchable subset
+        run: |
+          mvn test-compile
+          launchable split-subset --subset-id $( cat launchable-subset-id.txt ) --bin 4/4 maven  > launchable-subset.txt
+          cat launchable-subset.txt
+      - name: Test
+        run: mvn test -Dsurefire.includesFile=launchable-subset.txt
+      - name: Launchable record tests
+        if: always()
+        run: launchable record tests --subset-id $( cat launchable-subset-id.txt ) maven ./**/target/surefire-reports
```

If you success, your configuration like this

![image](https://user-images.githubusercontent.com/536667/192206848-ebafacf9-6702-4f12-8f35-29a2e2f63bf3.png)

This concludes the hands-on session. Next, let's see how it works in a real project.

___

Prev: [Hands-on 3](HANDSON3.md)

