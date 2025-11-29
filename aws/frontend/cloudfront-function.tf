# CloudFront Function to append index.html to directory requests

resource "aws_cloudfront_function" "url_rewrite" {
  name    = "${var.project_name}-url-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Append index.html to directory requests"
  publish = true
  code    = <<-EOT
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    
    // Check if URI ends with '/'
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    // Check if URI has no file extension
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }
    
    return request;
}
EOT
}
