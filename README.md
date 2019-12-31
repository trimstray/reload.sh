# `reload.sh`

<br>

<img src="https://i.imgur.com/QETbVXy.gif" align="center" title="reload.sh preview">

## Don't do it...

Please **don't do it on live systems** (e.g. production) or on your **private computer** where you **stored critical data**.

This recipe show you how to install fresh system where other system exist and running. It's really cool and amazing but very risky!

If you want to go into the chaos of monkey read on.

## Why I created it?

I like experiments because I love to know how things work. They allow me to understand and show me some of the more tricky concepts.

Long time ago, this way saved my life but it was crazy.

## How it works?

  > A beginner's guide of [reload.sh](https://trimstray.github.io/dee625b8b2e43917031e204d545f767b.html) <sup>[PL]</sup>

Set your archive with system backup to restore:

```bash
_build="/mnt/system-backup.tgz"
```

Set path to temporary system (optional):

```bash
_base="/mnt/minimal-base"
```

  > If you do not set this parameter, the temporary system will be downloaded automatically.

Set path to main system disk:

```bash
_disk="/dev/vda"
```

Run `reload.sh`:

```bash
./bin/reload.sh --base "$_base" --build "$_build" --disk "$_disk"
```

## Contributing

Before adding a pull request, please see the **[contributing guidelines](.github/CONTRIBUTING.md)**. All **suggestions/PR** are welcome!

## See also

* [`takeover.sh`](https://github.com/marcan/takeover.sh)

## Credits

| [![twitter/trimstray](https://avatars2.githubusercontent.com/u/31127917?s=140&v=4)](https://twitter.com/trimstray "Follow @trimstray on Twitter") |
|---|
| <p align="center"><a href="https://github.com/trimstray">trimstray</a></p> |

## License

GPLv3 : <http://www.gnu.org/licenses/>
