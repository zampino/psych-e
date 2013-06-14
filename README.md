# Psych::E

The _E_ nvironment missing in Psych.

## What it does

Assume your Internet, Rack or Filesystem environment
can resolve a URI `/remote/yaml` to
a valid YAML string like
	
	---
	remote:
      - data: stored
        somewhere: else

then

```
describe "yaml references in the wild" do
  let(:yaml) { YAML>>
---
some:
  nice: !ref /remote/yaml
  to:
    be: expanded
YAML }

  example "of reference resolution" do
    expect(Psych::E.load(yaml)).to
      be {some: {remote: [{data: "somewhere"}]},
          to: {be: "expanded"}}
  end
end
```

## References in Details
### Over the Internet

Assume a GET request to `https://nice.doc/far/away.yml` responds
with content type `text/yaml` and its body contains:

```
---
information: "from the net..."
to: be
used:
  - very
  - carefully
```

and

```
# my_home_file.myl
some:
  secure: !ref https://nice.doc/far/away.yml
```

then

```
Psych::E.load_file "my_home_file.yml" #=>
{some: {secure: {"information" =>  "from the net", "to" => "be", ... }}} 
```

### Over Rack

Assume you have

```
class MyRackApp < Sinatra::Base
  get "/bar/:param.yml", provides: :yaml do |param| 
    YAML.dump({some: ["local", param]})
  end
end
```
And you configure `Psych::E` in your program like
```
Psych::E.configure do |c|
  c.mount "/foo" => MyRackApp
end
```
and `home.yml` is
```
---
- I
- d
- like: !ref /foo/bar/info.yml
```
then

```
describe "Rack hosted yaml" do
  it "should resolve references through your application" do
    expect(YAML.load_file("home.yml")).to
      be ["I", "d", {"like" => {"some" => ["local", "info"]}}]
  end
end
```
### Over a local filesystem
Just tell `Psych::E` where to root your files. With
```
Psych::E.configure do |c|
  c.root= File.expand_path("some/folder", __dir__)
end
```
a reference `!ref sub/path.yml`
will be resolved to the content of the file
```
./some/folder/sub/path.yml
```
## It's Concurrent!

It uses Celluloid futures to resolve
remote nodes concurrently.

## Is it a revolutionary idea?

No. It is already drafted in the JSON world
as _JSON reference_. See [here](http://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03)

## Configuration
```
Psych::E.configure do |c|
  c.mount "/foo" => BarApp, "/schemas" => SchemaProviderApp
  # mounts your Rack applications (uses Rack::URLMap)

  c.root = "some/path"
  # roots your filesystem
  # defaults to Dir.pwd

  c.paranoid = false
  # will fail silently removing the referenced
  # node from the home manifest for failing resolutions
  # defaults to true which raises Psych::E::ResolutionFailed

  c.require_content_type = true
  # checks if the resolution response is of type
  # "text/yaml", "text/x-yaml" or the "application/" variants 
  # fails accordingly to the 'paranoid' setting above
  # defaults to false

  c.emit :ruby
  # possible choices:
  # - :yaml
  # - :ruby (default)
  # - :json short circuits YAML nodes to build a
  # resolved json object (available in future versions)
end
```

All of the above configuration methods are available to
single calls of load and will override the above (global) settings:
```
Psych.load_file "some.yml", emit: :json, mount: {"foo" => BarApp}
```

## Roadmap
* 0.1.5: will resolve URI fragments like `!ref /some/path#and/1/fragment` by traversing the yaml response through
* 0.2.0: will support a Psych::E::Cache to spare requests to the same resource.
  Useful in resolving the same resource but with different fragments.
* 0.2.5: will also emit json
* 0.9.0: will prevent circular references
* 1.0.0: ... well.

## Installation

Add this line to your application's Gemfile:

    gem 'psych-e'

And then execute:

    $ bundle

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
