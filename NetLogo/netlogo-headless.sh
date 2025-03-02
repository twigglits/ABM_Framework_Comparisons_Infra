#!/bin/bash

# BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR=/opt/netlogo

if [[ ${JAVA_HOME+1} ]]; then
  JAVA="${JAVA_HOME}/bin/java"
else
  echo "JAVA_HOME undefined, using java from path. For control over exact java version, set JAVA_HOME"
  JAVA="java"
fi;

# -Xmx1024m             use up to 1GB RAM (edit to increase)
# -Dfile.encoding=UTF-8 ensure Unicode characters in model files are compatible cross-platform

JVM_OPTS=(-Xmx8192m -Dfile.encoding=UTF-8 -Dnetlogo.extensions.dir="${BASE_DIR}/extensions" -Dnetlogo.models.dir="${BASE_DIR}/models" --add-exports=java.base/java.lang=ALL-UNNAMED --add-exports=java.desktop/sun.awt=ALL-UNNAMED --add-exports=java.desktop/sun.java2d=ALL-UNNAMED  )
ARGS=()

for arg in "$@"; do
  if [[ "$arg" == "--3D" ]]; then
    JVM_OPTS+=("-Dorg.nlogo.is3d=true")
  elif [[ "$arg" == -D* ]]; then
    JVM_OPTS+=("$arg")
  else
    ARGS+=("$arg")
  fi
done

ABSOLUTE_CLASSPATH="$BASE_DIR/lib/app/netlogo-6.3.0.jar"

# -classpath ....         specify jars
# org.nlogo.headless.Main specify we want headless, not GUI
# org.nlogo.app.App       specify we want GUI, not headless
# "${ARGS[0]}"            pass along any additional arguments

"$JAVA" "${JVM_OPTS[@]}" -classpath "$ABSOLUTE_CLASSPATH" org.nlogo.headless.Main "${ARGS[@]}"
