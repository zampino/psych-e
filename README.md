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

```ruby
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
      eq {some: {remote: [{data: "somewhere"}]},
          to: {be: "expanded"}}
  end
end
```

## References in Details
### Over the Internet

Assume a GET request to `https://nice.doc/far/away.yml` responds
with content type `text/yaml` and its body contains:

```yaml
---
information: "from the net..."
to: be
used:
  - very
  - carefully
```

and

```yaml
# my_home_file.myl
some:
  secure: !ref https://nice.doc/far/away.yml
```

then

```ruby
Psych::E.load_file "my_home_file.yml" #=>
{some: {secure: {"information" =>  "from the net", "to" => "be", ... }}}
```

### Over Rack

Assume you have

```ruby
class MyRackApp < Sinatra::Base
  get "/bar/:param.yml", provides: :yaml do |param|
    YAML.dump({some: ["local", param]})
  end
end
```

And you configure `Psych::E` in your program like
```ruby
Psych::E.configure do |c|
  c.mount "/foo" => MyRackApp
end
```

and `home.yml` is

```yaml
---
- I
- d
- like: !ref /foo/bar/info.yml
```
then

```ruby
describe "Rack hosted yaml" do
  it "should resolve references through your application" do
    expect(YAML.load_file("home.yml")).to
      be ["I", "d", {"like" => {"some" => ["local", "info"]}}]
  end
end
```
### Over a local filesystem

Just tell `Psych::E` where to root your files. With

```ruby
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

```ruby
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

```ruby
Psych.load_file "some.yml", emit: :json, mount: {"foo" => BarApp}
```

## Installation

Add this line to your application's Gemfile:

    gem 'psych-e'

And then execute:

    $ bundle
