# Hands-on 3. Run test with the Predictive Test Selection

In this section, edit`.github/workflows/pre-merge.md` and introduce the **subset** command.

You will:

1. Set up `launchable record subset` (Predictive Test Selection) with the observation option
1. Disable observation mode
1. Change subset target value
1. Add a new test case and check the Predictive Test Selection works correctly

Before you begin, create a new branch named `PR2`.

```
$ git switch main
$ git pull origin main
$ git switch -c PR2
$ git commit --allow-empty -m "introduce subset command"
$ git push origin PR2
```
 Then, create a pull request from `PR2` branch to `main` branch.

 ## Set up "launchable subset" command


Let's setup the **launchable subset** command with the [observation mode](https://docs.launchableinc.com/features/predictive-test-selection/observing-subset-behavior) option.

Update `.github/workflows/pre-merge.yml` as follows:
```diff
      - name: Launchable verify
        run: launchable verify
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
+     - name: launchable subset
+       run: |
+         launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
+         cat launchable-subset.txt
      - name: Test
        run: mvn test
```

<details>
<summary>Raw text for copying</summary>

```
- name: launchable subset
  run: |
    launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
    cat launchable-subset.txt
```

</details>
<br>

You can view the subset result log in the GitHub Actions log. For example (The ratio between the subset and the rest may vary.):

```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            2 |                  36.4706 |                  0.0516667 |
| Remainder |            2 |                  63.5294 |                  0.09      |
|           |              |                          |                            |
| Total     |            4 |                 100      |                  0.141667  |

Run `launchable inspect subset --subset-id XXX` to view full subset details
example.MulTest
example.DivTest
example.AddTest
example.SubTest
```

Next, use this subset result for testing.

```diff
      - name: Launchable verify
        run: launchable verify
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
      - name: launchable subset
        run: |
          launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
          cat launchable-subset.txt
      - name: Test
+       run: mvn test -Dsurefire.includesFile=launchable-subset.txt
      - name: Launchable record tests
         run: launchable record tests maven ./**/target/surefire-reports
```

<details>
<summary>Raw text for copying</summary>

```
run: mvn test -Dsurefire.includesFile=launchable-subset.txt
```

</details>
<br>

After the job succeeded, you can check the subset impact on web application. From the sidebar, go to  **Predictive Test Selection > Observe**:

<img src="https://user-images.githubusercontent.com/536667/195478410-6402773f-d232-46af-8543-24a7f6b67b4f.png">

<br>

![image](https://user-images.githubusercontent.com/536667/195477376-500d318a-b67a-4202-8c90-81ca6048dcc4.png)

## Stop observation mode

If you have confirmed the subset impact, remove the observation option and reduce the test durations.

Edit `.github/workflows/pre-merge.yml` as follows:
```diff
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
      - name: launchable subset
        run: |
          mvn test-compile
-         launchable subset --observation --target 50% maven src/test/java > launchable-subset.txt
+         launchable subset --target 50% maven src/test/java > launchable-subset.txt
          cat launchable-subset.txt
      - name: Test
        run: mvn test
```

<details>
<summary>Raw text for copying</summary>

```
launchable subset --target 50% maven src/test/java > launchable-subset.txt
```

</details>
<br>

You can confirm that the number of test cases executed has changed as follows (The test count may vary.):

**Test Log**

- Before
```
[INFO] Results:
[INFO]
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0
```

- After
```
[INFO] Results:
[INFO]
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0
```

**Subset Result**

- Before
```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             4 |             4 |              4 |              0 |                 0.0001 |
```

- After
```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             2 |             2 |              2 |              0 |                 0.0001 |
```

 ## Change subset target value

 There are three subset type.

 ```
 launchable subset \
    # one of:
    --target [PERCENTAGE]
    # or
    --confidence [PERCENTAGE]
    # or
    --time [STRING] \
    [other options...]
```

This time, change target value and confirm that the result changes.

```diff
      - name: launchable record build
        run: launchable record build --name ${{ github.run_id }}
      - name: launchable subset
        run: |
          mvn test-compile
-         launchable subset --target 50% maven src/test/java > launchable-subset.txt
+         launchable subset --target 25% maven src/test/java > launchable-subset.txt
          cat launchable-subset.txt
      - name: Test
```
<details>
<summary>Raw text for copying</summary>

```
launchable subset --target 25% maven src/test/java > launchable-subset.txt
```

</details>
<br>


The subset result will change as shown below. You can confirm that the number of subset candidates changes from 2 to 1. (The ratio between the subset and the rest may vary.)
```
|           |   Candidates |   Estimated duration (%) |   Estimated duration (min) |
|-----------|--------------|--------------------------|----------------------------|
| Subset    |            1 |                  9.63855 |                  0.0133333 |
| Remainder |            3 |                 90.3614  |                  0.125     |
|           |              |                          |                            |
| Total     |            4 |                100       |                  0.138333  |
```

## Add new test case

In this section, add a new function along with its test, and confirm that both the added test and its related tests are executed. You will add new function called `Exponentiation`.

First, add test code and dummy method to prevent compile errors.

Create the file `src/test/java/example/ExponentiationTest.java`
```java
package example;

import org.junit.Test;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;


public class ExponentiationTest {
  @Test
  public void exponentiation() {
    assertThat(new Exponentiation().calc(2, 5), is(32));
  }
}
```

Then, create the file `src/main/java/example/Exponentiation.java`
```java
package example;

public class Exponentiation {
  public int calc(int x, int y) {
    return 0;
  }
}
```

At this point, the  test will fail:

```
Run `launchable inspect subset --subset-id xxx` to view full subset details
example.ExponentiationTest
example.SubTest
```

The test results recorded on GitHub Actions will show:

```
|   Files found |   Tests found |   Tests passed |   Tests failed |   Total duration (min) |
|---------------|---------------|----------------|----------------|------------------------|
|             2 |             2 |              1 |              1 |                 0.0001 |
```

Now, implement the code:

```java
 public class Exponentiation {
   public int calc(int x, int y) {
-    return 0;
+    int exp = 1;
+    for (; y != 0; y--) {
+      exp = new Mul().calc(exp, x);
+    }
+    return exp;
   }
 }
```
<details>
<summary>Raw text for copying</summary>

```java
int exp = 1;
for (; y != 0; y--) {
  exp = new Mul().calc(exp, x);
}
return exp;
```

</details>
<br>

You can confirm the both `ExponentiationTest.java` and `MulTest.java` are selected for testing.

Finally, merge PR2 to main to complete this section.

You have learned how to introduce the **subset** command. You can confirm that the new test and its related tests were selected by **launchable subset**.

___

Prev: [Hands-on 2](HANDSON2.md)


