{{- define "streamingapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "streamingapp.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "streamingapp.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "streamingapp.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "streamingapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "streamingapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "streamingapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "streamingapp.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- printf "%s-secret" (include "streamingapp.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "streamingapp.mongoUri" -}}
{{- if .Values.secrets.externalMongoUri -}}
{{- .Values.secrets.externalMongoUri -}}
{{- else -}}
{{- printf "mongodb://%s:%s@%s-mongodb:27017/%s?authSource=admin" .Values.mongodb.username .Values.mongodb.password (include "streamingapp.fullname" .) .Values.mongodb.database -}}
{{- end -}}
{{- end -}}
