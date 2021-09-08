{{- define "chirpstack.gatewaybridge.labels" -}}
app.kubernetes.io/name: {{ template "chirpstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.gatewaybridge.image.tag }}
app.kubernetes.io/component: "{{ .Values.gatewaybridge.name }}"
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "chirpstack.gatewaybridge.backend" -}}
{{- $mqttSecret := .Values.gatewaybridge.integrations.mqtt.existingSecret | default "secret.not.set" | quote -}}
- name: INTEGRATION__MQTT__AUTH__GENERIC__SERVER
  value: {{ .Values.gatewaybridge.integrations.mqtt.server }}
- name: INTEGRATION__MQTT__AUTH__GENERIC__USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ $mqttSecret }}
      key: username
      optional: true
- name: INTEGRATION__MQTT__AUTH__GENERIC__PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $mqttSecret  }}
      key: password
      optional: true
- name: INTEGRATION__MQTT__AUTH__GENERIC____CLIENT_ID
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
{{- end -}}


{{- define "chirpstack.gatewaybridge.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.gatewaybridge.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.gatewaybridge.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}